import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Twin'Am logo palette
  static const Color primaryColor = Color(0xFF2196F3);    // Blue twin
  static const Color primaryLight = Color(0xFF4FC3F7);    // Light blue twin
  static const Color secondaryColor = Color(0xFF7CB342);  // Green twin
  static const Color secondaryLight = Color(0xFFAED581);  // Light green twin
  static const Color accentColor = Color(0xFF80DEEA);     // Cyan sparkles
  static const Color successColor = Color(0xFF66BB6A);    // Green success
  static const Color warningColor = Color(0xFFFFB74D);    // Warm amber
  static const Color dangerColor = Color(0xFFEF5350);     // Soft red

  static const List<Color> counterColors = [
    Color(0xFF2196F3),  // Blue twin
    Color(0xFF7CB342),  // Green twin
    Color(0xFF80DEEA),  // Cyan sparkle
    Color(0xFFFFB74D),  // Warm amber
    Color(0xFF66BB6A),  // Fresh green
    Color(0xFFEF5350),  // Soft red
    Color(0xFF4FC3F7),  // Sky blue
    Color(0xFFAED581),  // Light green
    Color(0xFFBA68C8),  // Soft purple
    Color(0xFFFF8A65),  // Peach
    Color(0xFF4DD0E1),  // Turquoise
    Color(0xFFF06292),  // Rose
  ];

  static const List<String> counterEmojis = [
    // Top habits (most popular)
    '💧', '🏃', '💪', '📖', '🧘', '☕', '😴', '🍎',
    // Health & wellness (all ≤ Unicode 9.0)
    '💊', '🥗', '📿', '💆', '🌿', '🥛', '🍵', '🍇',
    // Exercise & sport
    '🏋️', '🚴', '🏊', '🚶', '🥊', '⚽', '🏀', '🎾',
    // Work & learning
    '✏️', '📝', '📚', '🎓', '💻', '🎯', '📊', '⏰',
    // Lifestyle & creativity
    '🎵', '🎨', '📷', '🎮', '🏠', '🌱', '🌙', '🛁',
    // Motivation & tracking
    '🔥', '⭐', '🌟', '✅', '❤️', '🙏', '💰', '🏆',
    // Other
    '🍕', '🍺', '🚬', '📱', '🔢', '☀️', '🎁', '🌈',
  ];

  /// Couleur utilisable pour du texte ou une icône. En mode sombre, inchangée.
  /// En mode clair, les teintes pastel (ambre, cyan, vert clair) sont assombries
  /// jusqu'au contraste [minContrast] sur le fond des cartes (4.5 = texte normal,
  /// 3 = grands chiffres et icônes). Les fonds et barres gardent la couleur d'origine.
  static Color readable(Color color, Brightness brightness, {double minContrast = 4.5}) {
    if (brightness == Brightness.dark) return color;
    const background = Colors.white;
    var hsl = HSLColor.fromColor(color);
    while (_contrast(hsl.toColor(), background) < minContrast && hsl.lightness > 0.05) {
      hsl = hsl.withLightness(math.max(0, hsl.lightness - 0.02));
    }
    return hsl.toColor();
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFECEFF4),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D3436),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8EAF0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final darkBase = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E2A),
      textTheme: GoogleFonts.poppinsTextTheme(darkBase.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: const Color(0xFF2A2A3A),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF2A2A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2A2A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

extension ReadableColor on BuildContext {
  /// Raccourci de [AppTheme.readable] avec la luminosité du thème courant.
  Color readable(Color color, {double minContrast = 4.5}) =>
      AppTheme.readable(color, Theme.of(this).brightness, minContrast: minContrast);
}
