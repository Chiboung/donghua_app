// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_page_transitions.dart';
import 'app_text_styles.dart';

/// Shared, theme-agnostic TextButton style so every text button in the
/// app — dialog actions, "Forgot password?", "Show more" toggles, etc. —
/// looks deliberate and consistent instead of falling back to Material's
/// generic defaults. Only the foreground color differs per theme.
TextButtonThemeData _textButtonTheme(Color foreground) {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.disabled;
        return foreground;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return foreground.withValues(alpha: 0.14);
        }
        if (states.contains(WidgetState.hovered)) {
          return foreground.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return foreground.withValues(alpha: 0.1);
        }
        return Colors.transparent;
      }),
      textStyle: WidgetStatePropertyAll(
        AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(44, 40)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashFactory: InkRipple.splashFactory,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    ),
  );
}

/// Same glass look as the app's image/upload boxes (see
/// AppColors.glassFill / glassBorder), but as fixed literals since
/// ThemeData is built once and can't read BuildContext brightness.
InputDecorationTheme _inputDecorationTheme({
  required Color fill,
  required Color border,
  required Color labelColor,
}) {
  OutlineInputBorder side(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingM,
      vertical: AppDimensions.paddingM,
    ),
    border: side(border),
    enabledBorder: side(border),
    focusedBorder: side(AppColors.primary, 1.5),
    errorBorder: side(AppColors.error),
    focusedErrorBorder: side(AppColors.error, 1.5),
    // Matches AppColors.textHint — the muted gray used for hints
    // elsewhere in the app, so field labels read as one family.
    labelStyle: TextStyle(color: labelColor),
    floatingLabelStyle: TextStyle(color: labelColor),
    hintStyle: TextStyle(color: labelColor),
  );
}

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      // Covered by AppBackground's gradient in practice — this is just
      // the paint color for the first frame / any screen outside the
      // layout shells.
      scaffoldBackgroundColor: AppColors.glassCanvasLightTop,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      // Matches the glassFill/glassBorder tokens used by image boxes
      // and glass panels, so text fields look like the same material.
      inputDecorationTheme: _inputDecorationTheme(
        fill: Colors.white.withValues(alpha: 0.42),
        border: Colors.white.withValues(alpha: 0.75),
        labelColor: const Color(0xFF9CA3AF), // AppColors.textHint (light)
      ),
      // Individual screens use GlassAppBar instead of a plain AppBar, but
      // keep this transparent too so anything that falls back to a bare
      // AppBar still shows the aurora gradient through it rather than a
      // flat surface color.
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.lightTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: _textButtonTheme(AppColors.primary),
      pageTransitionsTheme: appPageTransitionsTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.glassCanvasDarkTop,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fill: Colors.white.withValues(alpha: 0.06),
        border: Colors.white.withValues(alpha: 0.14),
        labelColor: const Color(0xFF7A7A7A), // AppColors.textHint (dark)
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: AppTextStyles.h2.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: _textButtonTheme(AppColors.primary),
      pageTransitionsTheme: appPageTransitionsTheme,
    );
  }
}
