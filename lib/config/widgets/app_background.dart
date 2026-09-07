import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Gradient canvas with soft, blurred color blobs.
///
/// Glass panels (see [GlassContainer], [GlassAppBar]) are translucent —
/// on their own they need something behind them to catch and blur.
/// Drop this once behind a screen's content (the layout shells already
/// do this) and every glass surface above it will pick up a soft tint.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [AppColors.glassCanvasDarkTop, AppColors.glassCanvasDarkBottom]
                  : const [AppColors.glassCanvasLightTop, AppColors.glassCanvasLightBottom],
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: -50,
          child: _Blob(color: AppColors.auroraBlue, size: 240, opacity: isDark ? 0.32 : 0.5),
        ),
        Positioned(
          top: 140,
          right: -90,
          child: _Blob(color: AppColors.auroraPurple, size: 280, opacity: isDark ? 0.28 : 0.45),
        ),
        Positioned(
          bottom: -110,
          left: 10,
          child: _Blob(color: AppColors.auroraTeal, size: 260, opacity: isDark ? 0.22 : 0.4),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Blob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
