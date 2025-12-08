import 'package:flutter/material.dart';
import '../../../core/services/integration_test_service.dart';

class IntegrationTestsScreen extends StatefulWidget {
  const IntegrationTestsScreen({super.key});

  @override
  State<IntegrationTestsScreen> createState() => _IntegrationTestsScreenState();
}

class _IntegrationTestsScreenState extends State<IntegrationTestsScreen> {
  final IntegrationTestService _testService = IntegrationTestService();
  IntegrationTestReport? _report;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Pruebas de Integración'),
        actions: [
          if (_report != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isRunning ? null : _runTests,
              tooltip: 'Ejecutar de nuevo',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _report == null
          ? FloatingActionButton.extended(
              onPressed: _isRunning ? null : _runTests,
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Ejecutando...' : 'Ejecutar Pruebas'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isRunning && _report == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Ejecutando pruebas de integración...'),
            SizedBox(height: 8),
            Text(
              'Esto puede tomar unos segundos',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Pruebas de Integración',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifica la conexión y funcionamiento\nde todos los servicios de Supabase',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return _buildReport();
  }

  Widget _buildReport() {
    final report = _report!;

    return CustomScrollView(
      slivers: [
        // Resumen
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: report.failed == 0
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : report.passRate >= 80
                        ? [Colors.orange[400]!, Colors.orange[600]!]
                        : [Colors.red[400]!, Colors.red[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  report.failed == 0
                      ? Icons.check_circle
                      : report.passRate >= 80
                          ? Icons.warning
                          : Icons.error,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  report.failed == 0
                      ? '¡Todas las pruebas pasaron!'
                      : '${report.failed} prueba(s) fallaron',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Total', '${report.totalTests}', Colors.white),
                    _buildStatItem('Pasaron', '${report.passed}', Colors.white),
                    _buildStatItem(
                        'Fallaron', '${report.failed}', Colors.white),
                    _buildStatItem('Duración',
                        '${report.duration.inMilliseconds}ms', Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Barra de progreso
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasa de éxito: ${report.passRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: report.passRate / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      report.passRate >= 100
                          ? Colors.green
                          : report.passRate >= 80
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Resultados por categoría
        ...report.resultsByCategory.entries.map((entry) {
          return SliverToBoxAdapter(
            child: _buildCategorySection(entry.key, entry.value),
          );
        }),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<TestResult> results) {
    final passed = results.where((r) => r.passed).length;
    final total = results.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              passed == total ? Colors.green[100] : Colors.orange[100],
          child: Icon(
            passed == total ? Icons.check : Icons.warning,
            color: passed == total ? Colors.green : Colors.orange,
          ),
        ),
        title:
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$passed/$total pruebas pasaron'),
        children:
            results.map((result) => _buildTestResultItem(result)).toList(),
      ),
    );
  }

  Widget _buildTestResultItem(TestResult result) {
    return ListTile(
      leading: Icon(
        result.passed ? Icons.check_circle : Icons.cancel,
        color: result.passed ? Colors.green : Colors.red,
      ),
      title: Text(result.name),
      subtitle: Text(
        result.message,
        style: TextStyle(
          color: result.passed ? Colors.grey[600] : Colors.red[700],
        ),
      ),
      trailing: result.data != null
          ? IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showDataDialog(result),
            )
          : null,
    );
  }

  void _showDataDialog(TestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: result.data!.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text('${e.value}')),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _report = null;
    });

    try {
      final report = await _testService.runAllTests();
      if (mounted) {
        setState(() {
          _report = report;
          _isRunning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRunning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al ejecutar pruebas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
