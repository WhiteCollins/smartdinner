import 'package:flutter/material.dart';
import 'dart:async';

class AiPredictionsScreen extends StatefulWidget {
  const AiPredictionsScreen({Key? key}) : super(key: key);

  @override
  _AiPredictionsScreenState createState() => _AiPredictionsScreenState();
}

class _AiPredictionsScreenState extends State<AiPredictionsScreen> {
  late Future<List<dynamic>> _predictions;

  @override
  void initState() {
    super.initState();
    _predictions = _getSamplePredictions();
  }

  // Datos de ejemplo para demostración
  Future<List<dynamic>> _getSamplePredictions() async {
    // Simular un pequeño delay como si fuera una llamada real
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'item_id': '1',
        'item_name': 'Pasta Alfredo',
        'predicted_demand': 45,
        'level': 'high',
        'confidence': 92.5,
      },
      {
        'item_id': '2',
        'item_name': 'Hamburguesa Clásica',
        'predicted_demand': 38,
        'level': 'high',
        'confidence': 88.3,
      },
      {
        'item_id': '3',
        'item_name': 'Ensalada César',
        'predicted_demand': 25,
        'level': 'medium',
        'confidence': 85.7,
      },
      {
        'item_id': '4',
        'item_name': 'Pizza Margarita',
        'predicted_demand': 32,
        'level': 'high',
        'confidence': 90.1,
      },
      {
        'item_id': '5',
        'item_name': 'Sopa del Día',
        'predicted_demand': 15,
        'level': 'low',
        'confidence': 78.5,
      },
      {
        'item_id': '6',
        'item_name': 'Tacos de Pollo',
        'predicted_demand': 28,
        'level': 'medium',
        'confidence': 86.2,
      },
      {
        'item_id': '7',
        'item_name': 'Salmón a la Parrilla',
        'predicted_demand': 12,
        'level': 'low',
        'confidence': 82.0,
      },
      {
        'item_id': '8',
        'item_name': 'Wrap Vegetariano',
        'predicted_demand': 18,
        'level': 'medium',
        'confidence': 79.8,
      },
    ];
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _predictions = _getSamplePredictions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Predictions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Implement sort
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _predictions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error cargando predicciones',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay predicciones disponibles'),
              );
            } else {
              final predictions = snapshot.data!;
              return Column(
                children: [
                  // Banner de demostración
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Datos de ejemplo para demostración',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSummary(predictions),
                  Expanded(
                    child: ListView.builder(
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = predictions[index];
                        return _buildPredictionCard(prediction);
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummary(List<dynamic> predictions) {
    try {
      final highDemand = predictions.where((p) => p['level'] == 'high').length;
      final mediumDemand =
          predictions.where((p) => p['level'] == 'medium').length;
      final lowDemand = predictions.where((p) => p['level'] == 'low').length;

      final validConfidences = predictions
          .where((p) => p['confidence'] != null)
          .map((p) => (p['confidence'] is num)
              ? (p['confidence'] as num).toDouble()
              : 0.0)
          .toList();

      final averageConfidence = validConfidences.isNotEmpty
          ? validConfidences.reduce((a, b) => a + b) / validConfidences.length
          : 0.0;

      return Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('General Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('High demand: $highDemand items'),
              Text('Medium demand: $mediumDemand items'),
              Text('Low demand: $lowDemand items'),
              Text(
                  'Average confidence: ${averageConfidence.toStringAsFixed(2)}%'),
            ],
          ),
        ),
      );
    } catch (e) {
      return Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error generating summary: $e',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    final level = prediction['level'] ?? 'N/A';
    final color = _getColorForLevel(level);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            (prediction['predicted_demand'] ?? 0).toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(prediction['item_name'] ?? 'Unknown Item'),
        subtitle: Text('Demand: $level'),
        trailing: Text('Confidence: ${prediction['confidence'] ?? 'N/A'}%'),
      ),
    );
  }

  Color _getColorForLevel(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
