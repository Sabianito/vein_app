import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VeinTheme {
  static const Color maroon = Color(0xFF7A1C1C);
  static const Color maroonDeep = Color(0xFF5E1414);
  static const Color maroonBg = Color(0xFF6A1A1A);
  static const Color cream = Color(0xFFF5EFE6);
  static const Color creamSoft = Color(0xFFF0E7DA);
  static const Color blush = Color(0xFFF7E6E8);
  static const Color cardWhite = Color(0xFFFDFBFC);
  static const Color ink = Color(0xFF140808);

  static ThemeData premiumDark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final heading = GoogleFonts.cinzelTextTheme(base.textTheme);
    final body = GoogleFonts.interTextTheme(base.textTheme);
    final merged = body.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
      titleMedium: heading.titleMedium,
      titleSmall: heading.titleSmall,
    );

    final textTheme = merged.apply(
      bodyColor: cream,
      displayColor: cream,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: maroonBg,
      brightness: Brightness.dark,
      primary: cream,
      onPrimary: maroonDeep,
      surface: maroonBg,
      onSurface: cream,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: maroonBg,
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(letterSpacing: 2.6, fontWeight: FontWeight.w600),
        titleMedium: textTheme.titleMedium?.copyWith(letterSpacing: 1.6, fontWeight: FontWeight.w600),
        bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: 0.35),
        labelLarge: textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: cream,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: cream.withValues(alpha: 0.92)),
      ),
      iconTheme: IconThemeData(color: cream.withValues(alpha: 0.9)),
      dividerTheme: DividerThemeData(color: cream.withValues(alpha: 0.12)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream.withValues(alpha: 0.08),
        hintStyle: TextStyle(color: cream.withValues(alpha: 0.55)),
        labelStyle: TextStyle(color: cream.withValues(alpha: 0.78)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cream.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cream.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cream.withValues(alpha: 0.28)),
        ),
      ),
      cardTheme: CardThemeData(
        color: cream.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(cream.withValues(alpha: 0.92)),
          foregroundColor: const WidgetStatePropertyAll(maroonDeep),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(cream.withValues(alpha: 0.92)),
          side: WidgetStatePropertyAll(BorderSide(color: cream.withValues(alpha: 0.22))),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: maroonBg,
        selectedItemColor: cream,
        unselectedItemColor: cream.withValues(alpha: 0.55),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: cream,
        unselectedLabelColor: cream.withValues(alpha: 0.7),
        indicatorColor: cream.withValues(alpha: 0.85),
        dividerColor: cream.withValues(alpha: 0.12),
        labelStyle: TextStyle(letterSpacing: 0.6, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(letterSpacing: 0.4, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final colorScheme = base.colorScheme.copyWith(
      primary: maroon,
      onPrimary: cardWhite,
      secondary: maroonDeep,
      surface: cardWhite,
      onSurface: maroonDeep,
      outline: maroonDeep.withValues(alpha: 0.12),
    );

    final heading = GoogleFonts.playfairDisplayTextTheme(base.textTheme);
    final body = GoogleFonts.interTextTheme(base.textTheme);
    final merged = body.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
      titleMedium: heading.titleMedium,
      titleSmall: heading.titleSmall,
    );
    final textTheme = merged.apply(
      bodyColor: maroonDeep,
      displayColor: maroonDeep,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: blush,
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(letterSpacing: 0.6),
        titleMedium: textTheme.titleMedium?.copyWith(letterSpacing: 0.4),
        bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: 0.2),
        labelLarge: textTheme.labelLarge?.copyWith(letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: maroonDeep,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: maroonDeep,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: maroonDeep.withValues(alpha: 0.08),
      ),
      dividerTheme: DividerThemeData(
        color: maroonDeep.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: maroonDeep.withValues(alpha: 0.9)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        hintStyle: TextStyle(color: maroonDeep.withValues(alpha: 0.45)),
        labelStyle: TextStyle(color: maroonDeep.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: maroonDeep.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: maroonDeep.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: maroon.withValues(alpha: 0.55)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(maroon),
          foregroundColor: const WidgetStatePropertyAll(cardWhite),
          elevation: const WidgetStatePropertyAll(0.5),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(maroonDeep),
          side: WidgetStatePropertyAll(
            BorderSide(color: maroonDeep.withValues(alpha: 0.18)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: maroonDeep.withValues(alpha: 0.92),
        contentTextStyle: TextStyle(color: cardWhite.withValues(alpha: 0.96)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
