import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Frosted-glass replacement for a plain `AppBar`.
///
/// Blurs whatever's behind it — the [AppBackground] gradient, or content
/// scrolled underneath — instead of painting a flat surface color, so it
/// stays visually consistent with [GlassContainer] cards.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassFill(context),
            border: Border(bottom: BorderSide(color: AppColors.glassBorder(context))),
          ),
          child: AppBar(
            title: Text(title),
            centerTitle: false,
            actions: actions,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.onCanvas(context),
          ),
        ),
      ),
    );
  }
}
