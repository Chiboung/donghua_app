import 'package:flutter/material.dart';
import '../../mylist/screens/mylist_screen.dart';
import '../screens/button_nav_bar_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../add/screens/add_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/auth_gate.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';

/// Route name constants. Use these instead of hardcoded strings when
/// calling Navigator.pushNamed elsewhere in the app.
class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String sell = '/sell';
  static const String cart = '/cart';
  static const String profile = '/profile';
}

/// Central place that maps route names to screens.
///
/// [root] resolves to [AuthGate], which itself switches between the
/// login flow and [ButtonNavBarScreen] — the tabbed shell — based on
/// Firebase auth state, so most in-app navigation should switch tabs
/// rather than push a new route. The other routes exist for pushing a
/// tab's screen full-screen on top of the shell (e.g. deep links, or a
/// "view full profile" push from a notification) without going through
/// the bottom nav.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.root:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case AppRoutes.sell:
        return MaterialPageRoute(builder: (_) => const SellScreen());
      case AppRoutes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for "${settings.name}"')),
          ),
        );
    }
  }
}
