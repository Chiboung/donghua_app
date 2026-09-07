import 'package:flutter/material.dart';
class AppColors {
  AppColors._();

  // Brand colors — constant across themes.
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF9333EA);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color disabled = Color(0xFFBDBDBD);

  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF121212);
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);

  // ---- Glass canvas -------------------------------------------------
  // The gradient behind every frosted panel. Glass only reads as glass
  // when there's something colorful for it to blur — a flat white/black
  // background makes BackdropFilter invisible.
  static const Color glassCanvasLightTop = Color(0xFFEFF3FF);
  static const Color glassCanvasLightBottom = Color(0xFFF7EEFA);
  static const Color glassCanvasDarkTop = Color(0xFF0A0E1A);
  static const Color glassCanvasDarkBottom = Color(0xFF190F2B);

  // Soft accent blobs blurred into the canvas behind glass surfaces.
  static const Color auroraBlue = Color(0xFF60A5FA);
  static const Color auroraPurple = Color(0xFFC084FC);
  static const Color auroraTeal = Color(0xFF5EEAD4);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      _isDark(context) ? darkSurface : lightSurface;

  static Color border(BuildContext context) =>
      _isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB);

  static Color divider(BuildContext context) =>
      _isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB);
      
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);

  static Color textHint(BuildContext context) =>
      _isDark(context) ? const Color(0xFF7A7A7A) : const Color(0xFF9CA3AF);

  // ---- Glass surface tokens ------------------------------------------
  /// Base fill for a frosted panel — pair with a BackdropFilter blur.
  static Color glassFill(BuildContext context) => _isDark(context)
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.42);

  /// Slightly brighter fill, used as the top-left stop of a panel's
  /// gradient sheen so glass reads as curved/reflective rather than flat.
  static Color glassFillStrong(BuildContext context) => _isDark(context)
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white.withValues(alpha: 0.62);

  /// Hairline edge that catches the light on a glass panel.
  static Color glassBorder(BuildContext context) => _isDark(context)
      ? Colors.white.withValues(alpha: 0.14)
      : Colors.white.withValues(alpha: 0.75);

  /// Tint for text/icons sitting directly on the aurora canvas (e.g. an
  /// app bar title over the gradient) rather than inside a glass panel.
  static Color onCanvas(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : lightTextPrimary;
}

