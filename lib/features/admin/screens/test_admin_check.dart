import 'package:flutter/material.dart';
import 'package:smartdinner/core/services/supabase_service.dart';

class TestAdminCheckScreen extends StatefulWidget {
  const TestAdminCheckScreen({super.key});

  @override
  State<TestAdminCheckScreen> createState() => _TestAdminCheckScreenState();
}

class _TestAdminCheckScreenState extends State<TestAdminCheckScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  String _output = 'Presiona el botón para verificar...';
  bool _isLoading = false;

  Future<void> _checkAdminStatus() async {
    setState(() {
      _isLoading = true;
      _output = 'Verificando...';
    });

    try {
      // 1. Verificar usuario actual
      final currentUser = _supabaseService.currentUser;
      print('✅ Usuario actual: ${currentUser?.id}');
      print('✅ Email: ${currentUser?.email}');

      if (currentUser == null) {
        setState(() {
          _output = '❌ No hay usuario autenticado';
          _isLoading = false;
        });
        return;
      }

      String result = '=== DIAGNÓSTICO COMPLETO ===\n\n';
      result += '1. USUARIO DE AUTH:\n';
      result += '   ID: ${currentUser.id}\n';
      result += '   Email: ${currentUser.email}\n\n';

      // 2. Obtener perfil de usuario
      try {
        final userProfile =
            await _supabaseService.getUserProfile(currentUser.id);
        print('✅ Perfil obtenido: $userProfile');

        result += '2. PERFIL DE USUARIO (tabla public.users):\n';
        result += '   ✅ Perfil encontrado\n';
        result += '   ID: ${userProfile['id']}\n';
        result += '   Email: ${userProfile['email']}\n';
        result += '   Name: ${userProfile['name']}\n';
        result += '   Role: ${userProfile['role']}\n';
        result += '   Role Type: ${userProfile['role'].runtimeType}\n';
        result += '   Is Active: ${userProfile['is_active']}\n\n';

        result += '3. VERIFICACIÓN DE ROL:\n';
        final role = userProfile['role'];
        result += '   Role value: "$role"\n';
        result += '   Role == "admin": ${role == 'admin'}\n';
        result += '   Role length: ${role.toString().length}\n';
        result += '   Role bytes: ${role.toString().codeUnits}\n\n';

        // 4. Comparación exacta
        if (role == 'admin') {
          result += '   ✅ ROL ES ADMIN - Debería ver el dashboard\n';
        } else {
          result += '   ❌ ROL NO ES ADMIN\n';
          result += '   Valor actual: "$role"\n';
          result += '   Se esperaba: "admin"\n';
        }
      } catch (e) {
        print('❌ Error al obtener perfil: $e');
        result += '2. PERFIL DE USUARIO:\n';
        result += '   ❌ ERROR al obtener perfil\n';
        result += '   Error: $e\n';
        result += '   Tipo: ${e.runtimeType}\n\n';
        result += '3. POSIBLES CAUSAS:\n';
        result += '   - Usuario no existe en tabla public.users\n';
        result += '   - Políticas RLS bloqueando acceso\n';
        result += '   - Error de conexión a Supabase\n';
      }

      setState(() {
        _output = result;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error general: $e');
      setState(() {
        _output = '❌ ERROR GENERAL: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Test Admin Check'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkAdminStatus,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: const Text('VERIFICAR ESTADO ADMIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
