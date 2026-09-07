import 'package:flutter/material.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import '../../../config/layouts/mobile_layout.dart';
import '../../../config/layouts/responsive_layout.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/widgets/glass_container.dart';
import '../../home/screens/home_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../add/screens/add_screen.dart';
import '../../mylist/screens/mylist_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Root tabbed shell for the app.
///
/// On mobile this renders the native iOS "Liquid Glass" [NativeGlassNavBar]
/// (real `UITabBar` under the hood, via platform views), with "Add"
/// promoted to the bar's central [TabBarActionButton] — a common
/// marketplace pattern (Home/Categories/My List/Profile stay persistent
/// tabs, "+" just navigates to the Add screen without claiming a selected
/// state of its own) — rather than a fifth ordinary tab.
///
/// The old hand-rolled [_GlassBottomNav] is kept only as the native
/// bar's [fallback] for Android and pre-Liquid-Glass iOS, where it
/// still shows all 5 sections as plain tabs (no action-button concept
/// there). On tablet/desktop widths [ResponsiveLayout] swaps to a
/// glass [NavigationRail] instead, using the same tab state.
class ButtonNavBarScreen extends StatefulWidget {
  const ButtonNavBarScreen({super.key});

  @override
  State<ButtonNavBarScreen> createState() => _ButtonNavBarScreenState();
}

class _ButtonNavBarScreenState extends State<ButtonNavBarScreen> {
  // Index into _tabs / the IndexedStack below (0..4) — the single
  // source of truth for which screen is showing.
  int _stackIndex = 0;

  // Index into _barItems (0..3) — which persistent nav-bar tab last
  // brought us here. Kept separate from _stackIndex so that opening
  // Sell via the action button doesn't disturb which real tab is
  // shown as selected underneath it.
  int _selectedBarIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(), // 0
    CategoriesScreen(), // 1
    SellScreen(), // 2 
    CartScreen(), // 3
    ProfileScreen(), // 4
  ];

  /// The 5 sections as plain tabs, for the [_GlassBottomNav] fallback
  /// (Android / pre-Liquid-Glass iOS) — index matches [_tabs] directly.
  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
        icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Categories'),
    _NavItem(
      icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Add'),
    _NavItem(
        icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'My List'),
    _NavItem(
      icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  /// The 4 persistent tabs for [NativeGlassNavBar] — Sell is deliberately
  /// left out here since it's promoted to the action button instead.
  /// [_BarItem.tabIndex] maps each one back to its position in [_tabs].
  static const List<_BarItem> _barItems = [
    _BarItem(label: 'Home', sfSymbol: 'house', tabIndex: 0),
    _BarItem(label: 'Categories', sfSymbol: 'square.grid.2x2', tabIndex: 1),
    _BarItem(label: 'My List', sfSymbol: 'cart', tabIndex: 3),
    _BarItem(label: 'Profile', sfSymbol: 'person', tabIndex: 4),
  ];

  void _onFallbackTabSelected(int index) => setState(() => _stackIndex = index);

  void _onBarTabSelected(int barIndex) {
    setState(() {
      _selectedBarIndex = barIndex;
      _stackIndex = _barItems[barIndex].tabIndex;
    });
  }

  void _onSellTapped() => setState(() => _stackIndex = 2);

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps every tab's scroll position and form state
    // alive when switching, instead of rebuilding from scratch.
    final body = IndexedStack(index: _stackIndex, children: _tabs);

    return ResponsiveLayout(
      mobileBody: MobileLayout(
        body: body,
        bottomNavigationBar: NativeGlassNavBar(
          currentIndex: _selectedBarIndex,
          onTap: _onBarTabSelected,
          tintColor: AppColors.primary,
          actionButton: TabBarActionButton(
            symbol: 'plus',
            onTap: _onSellTapped,
          ),
          tabs: [
            for (final item in _barItems)
              NativeGlassNavBarItem(label: item.label, symbol: item.sfSymbol),
          ],
          // Android and pre-"Liquid Glass" iOS can't render the native
          // bar, so fall back to the old hand-rolled glass pill there —
          // shown as 5 plain tabs, since it has no action-button concept.
          fallback: _GlassBottomNav(
            selectedIndex: _stackIndex,
            items: _navItems,
            onTap: _onFallbackTabSelected,
          ),
        ),
      ),
    );
  }
}

/// Floating frosted-glass pill nav bar.
///
/// Sits inset from the screen edges (rather than spanning full-width)
/// so the aurora gradient behind it stays visible around its edges,
/// reinforcing the glass effect instead of hiding it behind an opaque bar.
///
/// The selected tab is marked by a pill-shaped highlight that slides
/// between tabs on tap. The highlight is inset evenly from the bar's
/// top/bottom/sides and its corner radius is derived from its own
/// height (`height / 2`) rather than copied from the outer bar's
/// radius — that's what keeps its curve a clean stadium shape and stops
/// it from clipping against the outer pill's corner at small widths.
class _GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  static const double _barHeight = 68;
  static const double _highlightInset = 6;

  const _GlassBottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppDimensions.paddingM,
        0,
        AppDimensions.paddingM,
        AppDimensions.paddingS,
      ),
      child: GlassContainer(
        borderRadius: 28,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;
              final highlightHeight = _barHeight - _highlightInset * 2;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    top: _highlightInset,
                    height: highlightHeight,
                    left: selectedIndex * itemWidth + _highlightInset,
                    width: itemWidth - _highlightInset * 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.glassFillStrong(context),
                        borderRadius: BorderRadius.circular(highlightHeight / 2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        SizedBox(
                          width: itemWidth,
                          child: _NavTapTarget(
                            item: items[i],
                            selected: i == selectedIndex,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavTapTarget extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTapTarget({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: selected ? 12.5 : 11.5,
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: selected ? 1.08 : 1.0,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  color: color,
                  size: selected ? 25 : 23,
                ),
              ),
              const SizedBox(height: 4),
              Text(item.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

/// One persistent tab in [NativeGlassNavBar]'s bar — see [ButtonNavBarScreen._barItems].
class _BarItem {
  final String label;
  final String sfSymbol;
  final int tabIndex;

  const _BarItem({required this.label, required this.sfSymbol, required this.tabIndex});
}
