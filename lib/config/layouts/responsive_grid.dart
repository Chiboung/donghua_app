// lib/shared/layouts/responsive_grid.dart

import 'package:flutter/material.dart';

/// Grid-column-count helper shared by every product/category/admin grid
/// in the app, so "how many columns at this width" is answered the same
/// way everywhere instead of each screen hardcoding its own `2`.
///
/// Uses the incoming [BoxConstraints] rather than [MediaQuery] so it
/// still gives the right answer inside a fixed-width region (e.g. next
/// to a [DesktopLayout] side panel), not just for the full window.
abstract class ResponsiveGrid {
  static int columnsForWidth(double width) {
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    return 2;
  }

  /// Same as [columnsForWidth], but for a denser grid (e.g. category
  /// tiles) that can afford one more column at every breakpoint.
  static int denseColumnsForWidth(double width) {
    if (width >= 1100) return 6;
    if (width >= 800) return 5;
    if (width >= 600) return 4;
    return 3;
  }
}

/// Drop-in replacement for `GridView.builder` with a fixed
/// `crossAxisCount` — same API, but the column count adapts to the
/// available width via [ResponsiveGrid.columnsForWidth].
///
/// Cell height is computed from real content rather than a single
/// guessed [childAspectRatio]: pass [imageAspectRatio] for the part of
/// the card that scales with column width (e.g. a 9:16 cover) and
/// [fixedContentExtent] for the part that doesn't (e.g. a text block
/// with a set number of lines). The cell height becomes
/// `columnWidth / imageAspectRatio + fixedContentExtent`, which stays
/// correct at every breakpoint instead of overflowing at narrow
/// column widths. If either is omitted, [childAspectRatio] is used
/// as before.
class ResponsiveProductGrid extends StatelessWidget {
  const ResponsiveProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.childAspectRatio = 0.68,
    this.imageAspectRatio,
    this.fixedContentExtent,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double childAspectRatio;
  final double? imageAspectRatio;
  final double? fixedContentExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ResponsiveGrid.columnsForWidth(constraints.maxWidth);

        SliverGridDelegate gridDelegate;
        if (imageAspectRatio != null && fixedContentExtent != null) {
          final horizontalPadding =
              (padding ?? EdgeInsets.zero).resolve(Directionality.of(context)).horizontal;
          final totalSpacing = crossAxisSpacing * (columns - 1);
          final columnWidth =
              (constraints.maxWidth - horizontalPadding - totalSpacing) / columns;
          final mainAxisExtent = columnWidth / imageAspectRatio! + fixedContentExtent!;
          gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: mainAxisExtent,
          );
        } else {
          gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          );
        }

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: itemCount,
          gridDelegate: gridDelegate,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
