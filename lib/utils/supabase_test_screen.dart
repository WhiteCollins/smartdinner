import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({Key? key}) : super(key: key);

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String _testResult = 'Esperando prueba...';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Probando configuración...';
    });

    try {
      final url = SupabaseConfig.supabaseUrl;
      final key = SupabaseConfig.supabaseAnonKey;
      
      if (url.isEmpty || key.isEmpty) {
        setState(() {
          _testResult = '❌ ERROR: Credenciales vacías\n\n'
              'URL: ${url.isEmpty ? "VACÍO" : url}\n'
              'Key: ${key.isEmpty ? "VACÍO" : "presente (${key.length} caracteres)"}';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _testResult = '✅ Credenciales cargadas\n\n'
            'URL: $url\n'
            'Key: ${key.substring(0, 30)}...\n\n'
            '📡 Probando conexión a Supabase...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Probar consulta simple
      final response = await SupabaseConfig.client
          .from('users')
          .select('id')
          .limit(1);

      setState(() {
        _testResult = '✅ CONEXIÓN EXITOSA!\n\n'
            'URL: $url\n'
            'Respuesta: ${response.length} registros encontrados\n\n'
            '✓ La conexión con Supabase funciona correctamente';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _testResult = '❌ ERROR de conexión:\n\n$e\n\n'
            '📋 Verifica:\n'
            '1. Que el archivo .env tenga las credenciales correctas\n'
            '2. Que la URL sea https://dftgnfvzrrhfegrqahyw.supabase.co\n'
            '3. Que la tabla users exista en Supabase\n'
            '4. Que las políticas RLS permitan lectura';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Probando registro de cuenta...';
    });

    try {
      final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
      final testPassword = 'Test123456!';
      
      setState(() {
        _testResult = '📝 Creando cuenta de prueba...\n\n'
            'Email: $testEmail\n'
            'Password: $testPassword';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final response = await SupabaseConfig.auth.signUp(
        email: testEmail,
        password: testPassword,
      );

      if (response.user != null) {
        setState(() {
          _testResult = '✅ REGISTRO EXITOSO!\n\n'
              'User ID: ${response.user!.id}\n'
              'Email: ${response.user!.email}\n'
              'Created: ${response.user!.createdAt}\n\n'
              '✓ El registro de usuarios funciona correctamente';
          _isLoading = false;
        });
      } else {
        setState(() {
          _testResult = '❌ Registro falló: No se retornó usuario\n\n'
              'Esto puede significar que:\n'
              '1. Email confirmation está activado en Supabase\n'
              '2. Hay un problema con las políticas RLS';
          _isLoading = false;
        });
      }

    } catch (e) {
      String errorMsg = e.toString();
      String advice = '';
      
      if (errorMsg.contains('User already registered')) {
        advice = '✓ Este es un buen signo, significa que el registro funciona';
      } else if (errorMsg.contains('Email not confirmed')) {
        advice = '⚠️ Ve a Supabase > Authentication > Settings\n'
            'y desactiva "Enable email confirmations"';
      } else if (errorMsg.contains('rate limit')) {
        advice = '⚠️ Demasiados intentos, espera un momento';
      }
      
      setState(() {
        _testResult = '❌ ERROR en registro:\n\n$errorMsg\n\n$advice';
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Probando login con cuenta admin...';
    });

    try {
      const adminEmail = 'admin@smartdinner.com';
      const adminPassword = '123456';

      setState(() {
        _testResult = '🔐 Intentando login...\n\n'
            'Email: $adminEmail\n'
            'Password: $adminPassword';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final response = await SupabaseConfig.auth.signInWithPassword(
        email: adminEmail,
        password: adminPassword,
      );

      if (response.user != null) {
        setState(() {
          _testResult = '✅ LOGIN EXITOSO!\n\n'
              'User ID: ${response.user!.id}\n'
              'Email: ${response.user!.email}\n'
              'Role: ${response.user!.userMetadata?['role'] ?? 'No definido'}\n\n'
              '✓ El login funciona correctamente';
          _isLoading = false;
        });
      } else {
        setState(() {
          _testResult = '❌ Login falló: No se retornó usuario';
          _isLoading = false;
        });
      }

    } catch (e) {
      String errorMsg = e.toString();
      String advice = '';
      
      if (errorMsg.contains('Invalid login credentials')) {
        advice = '❌ El usuario admin NO existe en Supabase\n\n'
            '📋 Para crear el usuario admin:\n'
            '1. Ve a https://app.supabase.com/project/dftgnfvzrrhfegrqahyw\n'
            '2. Click en Authentication > Users\n'
            '3. Click en "Add user"\n'
            '4. Email: admin@smartdinner.com\n'
            '5. Password: 123456\n'
            '6. Auto Confirm User: ✓ ACTIVADO\n'
            '7. Click "Create User"';
      } else if (errorMsg.contains('Email not confirmed')) {
        advice = '⚠️ El email no está confirmado\n\n'
            'Ve a Supabase > Authentication > Users\n'
            'Busca al usuario y confírmalo manualmente';
      }
      
      setState(() {
        _testResult = '❌ ERROR en login:\n\n$errorMsg\n\n$advice';
        _isLoading = false;
      });
    }
  }

  Future<void> _createAdminInstructions() async {
    setState(() {
      _testResult = '''
📖 INSTRUCCIONES PARA CREAR USUARIO ADMIN

1️⃣ Ve a tu proyecto Supabase:
   https://app.supabase.com/project/dftgnfvzrrhfegrqahyw

2️⃣ En el menú lateral, click en:
   Authentication > Users

3️⃣ Click en el botón verde "Add user"

4️⃣ Completa el formulario:
   • Email: admin@smartdinner.com
   • Password: 123456
   • Auto Confirm User: ✓ ACTIVADO (importante!)

5️⃣ Click en "Create User"

6️⃣ Luego ve a SQL Editor y ejecuta:

INSERT INTO public.users (
    id,
    name,
    email,
    phone,
    role,
    is_active,
    email_verified
)
SELECT 
    id,
    'Admin SmartDinner',
    email,
    '809-555-0001',
    'admin',
    true,
    true
FROM auth.users
WHERE email = 'admin@smartdinner.com'
ON CONFLICT (id) DO UPDATE SET
    role = 'admin',
    email_verified = true;

7️⃣ Vuelve aquí y presiona "3. Probar Login Admin"
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Supabase'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🔧 Herramienta de Diagnóstico',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ejecuta las pruebas en orden',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: const Icon(Icons.wifi),
                label: const Text('1. Probar Conexión a Supabase'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testSignUp,
                icon: const Icon(Icons.person_add),
                label: const Text('2. Probar Registro de Usuario'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testLogin,
                icon: const Icon(Icons.login),
                label: const Text('3. Probar Login Admin'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _createAdminInstructions,
                icon: const Icon(Icons.help_outline),
                label: const Text('📖 ¿Cómo crear usuario admin?'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'RESULTADO:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Ejecutando prueba...'),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: SelectableText(
                            _testResult,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
