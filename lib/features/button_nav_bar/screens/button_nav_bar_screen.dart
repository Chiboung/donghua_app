import 'package:flutter/material.dart';
import 'package:hydro_glass_nav_bar/hydro_glass_nav_bar.dart';
import '../../home/screens/home_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../mylist/screens/mylist_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../add/screens/add_screen.dart';

class ButtonNavBarScreen extends StatefulWidget {
  const ButtonNavBarScreen({super.key});

  @override
  State<ButtonNavBarScreen> createState() => _ButtonNavBarScreenState();
}

class _ButtonNavBarScreenState extends State<ButtonNavBarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<Widget> _mainTabs = [
    HomeScreen(),       // Index 0
    CategoriesScreen(), // Index 1
    AddScreen(),        // Index 2
    MyListScreen(),     // Index 3
    ProfileScreen(),    // Index 4
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mainTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ពិនិត្យមើលថា Keyboard កំពុងបើក ឬអត់
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures if desired
            children: _mainTabs,
          ),
          
          // បង្ហាញ HydroGlassNavBar តែពេល Keyboard មិនទាន់បើក (isKeyboardOpen == false)
          if (!isKeyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HydroGlassNavBar(
                controller: _tabController,
                items: const [
                  HydroGlassNavItem(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                  ),
                  HydroGlassNavItem(
                    label: 'Categories',
                    icon: Icons.grid_view_outlined,
                    selectedIcon: Icons.grid_view,
                  ),
                  HydroGlassNavItem(
                    icon: Icons.add_circle_outline,
                    label: 'Add',
                    selectedIcon: Icons.add_circle,
                  ),
                  HydroGlassNavItem(
                    label: 'My List',
                    icon: Icons.list_alt_outlined,
                    selectedIcon: Icons.list_alt,
                  ),
                  HydroGlassNavItem(
                    label: 'Profile',
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}