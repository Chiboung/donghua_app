import 'package:flutter/material.dart';

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final incomingSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curved);

    final outgoingFade = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: outgoingFade,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(position: incomingSlide, child: child),
      ),
    );
  }
}

final PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: const AppPageTransitionsBuilder(),
    TargetPlatform.iOS: const AppPageTransitionsBuilder(),
    TargetPlatform.macOS: const AppPageTransitionsBuilder(),
    TargetPlatform.windows: const AppPageTransitionsBuilder(),
    TargetPlatform.linux: const AppPageTransitionsBuilder(),
    TargetPlatform.fuchsia: const AppPageTransitionsBuilder(),
  },
);
