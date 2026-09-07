// import 'package:flutter/material.dart';

// class ResponsiveLayout extends StatelessWidget {
//   final Widget mobileLayout;
//   final Widget? tabletLayout;

//   const ResponsiveLayout({
//     super.key,
//     required this.mobileLayout,
//     this.tabletLayout,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth >= 600 && tabletLayout != null) {
//           return tabletLayout!;
//         }
//         return mobileLayout;
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktopBody ?? tabletBody ?? mobileBody;
        } else if (constraints.maxWidth >= 600) {
          return tabletBody ?? mobileBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
}