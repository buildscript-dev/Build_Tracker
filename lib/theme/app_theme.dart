import 'package:flutter/material.dart';

/// Dark, sharp, "brutal premium" look. Near-black canvas, hard red urgency,
/// green for earned completion. Built to feel like a tool an operator uses,
/// not a cute habit app.
class AppTheme {
  static const bg = Color(0xFF0A0A0B);
  static const surface = Color(0xFF151518);
  static const surfaceHi = Color(0xFF1E1E22);
  static const line = Color(0xFF2A2A30);
  static const red = Color(0xFFFF3B30);
  static const green = Color(0xFF30D158);
  static const amber = Color(0xFFFFB020);
  static const blue = Color(0xFF0A84FF);
  static const textHi = Color(0xFFF5F5F7);
  static const textMid = Color(0xFFA0A0A8);
  static const textLo = Color(0xFF6A6A72);

  static const physical = Color(0xFF0A84FF);
  static const mental = Color(0xFFBF5AF2);
  static const financial = Color(0xFF30D158);
  static const deepwork = Color(0xFFFFB020);

  static Color categoryColor(String c) {
    switch (c) {
      case 'physical':
        return physical;
      case 'mental':
        return mental;
      case 'financial':
        return financial;
      case 'deepwork':
        return deepwork;
      default:
        return textMid;
    }
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: red,
        secondary: green,
        onSurface: textHi,
      ),
      cardColor: surface,
      dividerColor: line,
      textTheme: base.textTheme.apply(
        bodyColor: textHi,
        displayColor: textHi,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textHi,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: red.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHi,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  static const cardRadius = 16.0;
}
