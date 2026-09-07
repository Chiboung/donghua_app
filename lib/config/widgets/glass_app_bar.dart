import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Frosted-glass replacement for a plain `AppBar`.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassFill(context),
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder(context)),
            ),
          ),
          child: SafeArea(
            bottom: false, // យកតែ top padding សម្រាប់ status bar
            child: SizedBox(
              height: kToolbarHeight,
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
        ),
      ),
    );
  }

  // កែប្រែ preferredSize ឱ្យបូកបញ្ចូល height របស់ Status Bar 
  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight +
            (WidgetsBinding.instance.platformDispatcher.implicitView?.padding.top ?? 0) /
                (WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio ?? 1),
      );
}