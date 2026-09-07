import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/widgets/app_background.dart';
import '../../button_nav_bar/screens/button_nav_bar_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

/// Sits at the app root and switches between [LoginScreen] and
/// [ButtonNavBarScreen] as Firebase's auth state changes — signing in,
/// signing up, and signing out (e.g. from the Profile tab) all flow
/// through here without any manual navigation calls.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoading();
        }
        final user = snapshot.data;
        if (user != null) {
          // Fire-and-forget: makes sure a `users/{uid}` role doc exists
          // for this account. Safe to call on every sign-in — it's a
          // no-op once the doc is there — and safe to not await, since
          // it only ever *creates* a default doc, never blocks access.
          UserService.instance.ensureUserDocument(user);
          return const ButtonNavBarScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
