import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'config/layouts/app_responsive_bound.dart';
import 'config/theme/app_colors.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';
import 'features/button_nav_bar/routers/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Must run before runApp — EasyLoading.init() below wires the config
  // into the widget tree on first frame, so it needs to already be set.
  loadingConfig();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

void loadingConfig() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColors.primary
    ..backgroundColor = AppColors.darkSurface
    ..indicatorColor = AppColors.primary
    ..textColor = AppColors.darkTextPrimary
    ..maskColor = Colors.black.withValues(alpha: 0.4)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
    scrollbars: false,
  ),
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // AuthGate decides between the login flow and the tabbed shell
      // based on Firebase auth state, instead of hardcoding either one.
      home: const AuthGate(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      // EasyLoading.init() must own this slot directly — wrapping its
      // *result* in another builder (as opposed to composing through
      // its own `builder` param) re-creates a new Host on every
      // rebuild instead of reusing one, which is what throws "Bad
      // state: EasyLoading supports one active Host".
      builder: EasyLoading.init(
        builder: (context, child) => AppResponsiveBound(child: child),
      ),
    );
  }
}
