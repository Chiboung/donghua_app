import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

/// A frosted-glass panel: blurs whatever's behind it (see [AppBackground])
/// and fills with a translucent gradient sheen, a hairline light-catching
/// border, and a soft shadow to lift it off the canvas.
///
/// Drop-in replacement for a plain `Container` with a solid surface color
/// — use it for cards, list panels, and form sections.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final AlignmentGeometry? alignment;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppDimensions.radiusL,
    this.blurSigma = 20,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
            alignment: alignment,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.glassBorder(context)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.glassFillStrong(context),
                  AppColors.glassFill(context),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
