// lib/shared/layouts/app_responsive_bound.dart

import 'package:flutter/material.dart';

/// Caps and centers the *entire* app's content on large screens.
///
/// Individual screens already have their own mobile/tablet/desktop
/// bodies (see [ResponsiveLayout], [MobileLayout], [TabletLayout],
/// [DesktopLayout]), but a lot of them — and every screen that hasn't
/// been split into per-size bodies yet — just render a single
/// [Scaffold] that stretches edge-to-edge no matter how wide the
/// window gets. Plugged into `MaterialApp.builder`, this wrapper fixes
/// that for the whole app in one place: on anything wider than the
/// tablet breakpoint, the current screen is capped at [maxWidth] and
/// centered, with a neutral background filling the leftover space on
/// each side, so text lines and rows stay a readable length instead of
/// stretching across an ultrawide monitor.
///
/// Deliberately width-only — height is left alone so bottom sheets,
/// snackbars, and the on-screen keyboard behave exactly as before, and
/// [MediaQuery]/`LayoutBuilder`-based breakpoint checks elsewhere
/// (`ResponsiveLayout.isDesktop`, etc.) keep seeing the real device
/// width rather than the capped one, since [MediaQuery] doesn't get
/// re-derived from a plain [ConstrainedBox].
class AppResponsiveBound extends StatelessWidget {
  const AppResponsiveBound({super.key, required this.child, this.maxWidth = 1440});

  final Widget? child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) return content;

        return ColoredBox(
          // Matches the app's own background so the letterboxed strips
          // don't read as a stray, differently-colored gap.
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: SizedBox(width: maxWidth, height: constraints.maxHeight, child: content),
          ),
        );
      },
    );
  }
}
