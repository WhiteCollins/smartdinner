import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/themes.dart';
import 'core/state/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Variables de entorno cargadas correctamente');
  } catch (e) {
    print('❌ Error al cargar .env: $e');
  }

  // Inicializar Supabase con las variables de entorno
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('❌ Error al inicializar Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'SmartDinner',
            theme: AppThemes.lightTheme.copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(),
            ),
            darkTheme: AppThemes.darkTheme.copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(),
            ),
            themeMode: theme.mode,
            // Arranque directo en la pantalla de Login
            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
