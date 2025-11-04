import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Obtener credenciales desde el archivo .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    try {
      // Validar que las credenciales existan
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Error: SUPABASE_URL o SUPABASE_ANON_KEY no están configurados en el archivo .env'
        );
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      
      print('✅ Supabase inicializado correctamente');
      print('📍 URL: $supabaseUrl');
    } catch (e) {
      print('❌ Error al inicializar Supabase: $e');
      rethrow;
    }
  }

  // Getters para acceso fácil
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;
  static SupabaseQueryBuilder from(String table) => Supabase.instance.client.from(table);
  static RealtimeChannel channel(String name) => Supabase.instance.client.channel(name);
}
