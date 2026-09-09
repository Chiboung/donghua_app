import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ថែម Import នេះ ដើម្បីប្រើ SystemChrome & SystemUiOverlayStyle
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'config/layouts/app_responsive_bound.dart';
import 'config/theme/app_colors.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';
import 'features/button_nav_bar/routers/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // កំណត់ Status Bar ឱ្យលូន Edge-to-Edge និងមាន Background Transparent
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const AuthGate(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      // builder: EasyLoading.init(
      //   builder: (context, child) => AppResponsiveBound(child: child),
      // ),
      builder: (context, child) {
        // Pass child through EasyLoading first
        final easyLoadingBuilder = EasyLoading.init();
        return AppResponsiveBound(
          child: easyLoadingBuilder(context, child),
        );
      },
    );
  }
}