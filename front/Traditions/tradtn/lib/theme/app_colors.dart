import 'package:flutter/material.dart';

class AppColors {
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color neonPink = Color(0xFFF472B6);
  static const Color neonGreen = Color(0xFF34D399);

  static const Color darkBackground = Color(0xFF0B0F14);
  static const Color darkBackgroundAlt = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceAlt = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF1F2937);

  static const Color lightBackground = Color(0xFFF7F8FB);
  static const Color lightBackgroundAlt = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF2F4F8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color error = Color(0xFFF87171);
  static const Color success = Color(0xFF34D399);

  static const Gradient darkBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0B0F14),
      Color(0xFF0F172A),
      Color(0xFF0B0F14),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient lightBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFF7F8FB),
      Color(0xFFEFF2F7),
      Color(0xFFF7F8FB),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color glassDarkFill = Color(0x14FFFFFF);
  static const Color glassDarkStroke = Color(0x33FFFFFF);
  static const Color glassLightFill = Color(0xCCFFFFFF);
  static const Color glassLightStroke = Color(0x22000000);
}
