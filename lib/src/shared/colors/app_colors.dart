import 'package:flutter/material.dart';

/// Paleta de cores do FastLocation.
abstract final class AppColors {
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryDark = Color(0xFF002171);
  static const Color accent = Color(0xFFFF8F00);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);

  /// Overlay semitransparente usado na tela de loading (alpha ~ 45%).
  static const Color loadingOverlay = Color(0x73000000);

  /// Sombra suave dos cards (alpha ~ 8%).
  static const Color shadow = Color(0x14000000);
}
