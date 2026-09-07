import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class MobileLayout extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const MobileLayout({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The gradient below fully covers this — just a safe paint color
      // before the first frame lays out.
      backgroundColor: Colors.transparent,
      appBar: appBar,
      drawer: drawer,
      // Lets the body's gradient run underneath the floating glass nav
      // bar instead of the nav bar reserving an opaque strip.
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          body,
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
