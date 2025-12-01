import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Paleta híbrida: Qik × Code Geass
/// Fusión tecnológica con distinción premium para SmartDinner
const Color kPrimaryBlue =
    Color(0xFF003A70); // Azul Nocturno Qik - Base tecnológica
const Color kSecondaryPurple =
    Color(0xFF5B2C6F); // Morado Imperial - Profundidad y distinción
const Color kAccentRed = Color(0xFFE63946); // Rojo Geass - Energía y atención
const Color kAccentGold = Color(0xFFFFD166); // Dorado Luxury - Detalles premium
const Color kAccentCyan =
    Color(0xFF26A9FF); // Azul Celeste Qik - Contraste digital
const Color kBackgroundDark = Color(0xFF0D0D0D); // Fondo oscuro elegante
const Color kBackgroundLight = Color(0xFFF5F5F5); // Fondo claro
const Color kSurfaceWhite = Color(0xFFFFFFFF); // Tarjetas
const Color kTextPrimary = Color(0xFFFFFFFF); // Texto principal (sobre oscuro)
const Color kTextSecondary =
    Color(0xFF3A3A3A); // Texto secundario (sobre claro)
const Color kSuccessGreen = Color(0xFF2ECC71);
const Color kErrorRed = Color(0xFFE63946); // Reutilizamos el Rojo Geass
const Color kDividerGray = Color(0xFFE0E0E0);

class AppThemes {
  // 🌞 LIGHT THEME - Fondo claro para landing/marketing
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: kPrimaryBlue, // Azul Nocturno para navbar/botones
        onPrimary: kTextPrimary,
        secondary: kAccentCyan, // Azul Celeste para botones secundarios
        onSecondary: kTextPrimary,
        tertiary: kSecondaryPurple, // Morado Imperial para secciones premium
        onTertiary: kTextPrimary,
        surface: kBackgroundLight,
        onSurface: kTextSecondary,
        error: kErrorRed,
        onError: kTextPrimary,
      ),
      textTheme: _buildLightTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: kPrimaryBlue,
        foregroundColor:
            kTextPrimary, // Blanco para contraste sobre azul oscuro
        titleTextStyle: TextStyle(
          color: kTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: kTextPrimary),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 3,
        color: kSurfaceWhite,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: kDividerGray,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: kPrimaryBlue),

      // 🔘 Botones consistentes
      elevatedButtonTheme: _elevatedButtonTheme(kAccentCyan, kTextPrimary),
      filledButtonTheme: _filledButtonTheme(kAccentCyan, kTextPrimary),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryBlue,
          side: const BorderSide(color: kPrimaryBlue, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kAccentRed,
        foregroundColor: Colors.white,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: kBackgroundLight,
        selectedColor: kAccentCyan.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: kTextSecondary),
        secondarySelectedColor: kSecondaryPurple.withValues(alpha: 0.1),
        side: const BorderSide(color: kDividerGray),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDividerGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDividerGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentCyan, width: 1.5),
        ),
        hintStyle: const TextStyle(color: kTextSecondary),
        labelStyle: const TextStyle(color: kTextSecondary),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kAccentCyan,
        selectionColor: Color(0x3326A9FF),
        selectionHandleColor: kAccentCyan,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: kTextPrimary, // Blanco para texto seleccionado
        unselectedLabelColor: Color(0xFFB0BEC5), // Gris claro para no seleccionado
        indicatorColor: kAccentCyan,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kSurfaceWhite,
        selectedItemColor: kAccentCyan,
        unselectedItemColor: kPrimaryBlue,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // 🌙 DARK THEME - Dashboard oscuro elegante
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: kSecondaryPurple, // Morado Imperial para elementos principales
        onPrimary: kTextPrimary,
        secondary: kAccentCyan, // Azul Celeste para acciones secundarias
        onSecondary: kTextPrimary,
        tertiary: kAccentGold, // Dorado para detalles premium
        onTertiary: kBackgroundDark,
        surface: kBackgroundDark,
        onSurface: kTextPrimary,
        error: kErrorRed,
        onError: kTextPrimary,
      ),
      textTheme: _buildDarkTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: kSecondaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 3,
        color: Color(0xFF1E1E1E),
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF424242)),
      elevatedButtonTheme: _elevatedButtonTheme(kAccentCyan, Colors.white),
      filledButtonTheme: _filledButtonTheme(kAccentCyan, Colors.white),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: kAccentGold, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kAccentRed,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: kAccentCyan.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: Colors.white),
        secondarySelectedColor: kSecondaryPurple.withValues(alpha: 0.25),
        side: const BorderSide(color: Color(0xFF424242)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentCyan, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kAccentCyan,
        selectionColor: Color(0x3326A9FF),
        selectionHandleColor: kAccentCyan,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: kTextPrimary, // Blanco para texto seleccionado
        unselectedLabelColor: Color(0xFFB0BEC5), // Gris claro para no seleccionado
        indicatorColor: kAccentGold, // Dorado para indicador en tema oscuro
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: kAccentCyan,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // 🔤 TEXT THEMES
  static TextTheme _buildLightTextTheme() {
    final base = GoogleFonts.openSansTextTheme();
    return base
        .apply(bodyColor: kTextSecondary, displayColor: kTextSecondary)
        .copyWith(
          displayLarge: GoogleFonts.poppins(textStyle: base.displayLarge)
              .copyWith(fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.poppins(textStyle: base.headlineLarge)
              .copyWith(fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.poppins(textStyle: base.titleLarge)
              .copyWith(fontWeight: FontWeight.w600),
        );
  }

  static TextTheme _buildDarkTextTheme() {
    final base = GoogleFonts.openSansTextTheme(ThemeData.dark().textTheme);
    return base
        .apply(bodyColor: Colors.white, displayColor: Colors.white)
        .copyWith(
          displayLarge: GoogleFonts.poppins(textStyle: base.displayLarge)
              .copyWith(fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.poppins(textStyle: base.headlineLarge)
              .copyWith(fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.poppins(textStyle: base.titleLarge)
              .copyWith(fontWeight: FontWeight.w600),
        );
  }

  // 🧩 Helpers for consistent button styling
  static ElevatedButtonThemeData _elevatedButtonTheme(Color bg, Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(Color bg, Color fg) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    );
  }
}
