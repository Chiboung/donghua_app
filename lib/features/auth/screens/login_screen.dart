import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/app_background.dart';
import '../../../config/widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../widgets/google_sign_in_button.dart';
import 'email_login_screen.dart';
import 'signup_screen.dart';

/// Entry-point auth screen: a simple chooser between "Continue with
/// Email" (pushes [EmailLoginScreen]) and "Continue with Google" (signs
/// in immediately, no extra screen needed since Google's own account
/// picker handles the rest).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _googleSubmitting = false;
  String? _errorText;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleSubmitting = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();
      // On success, AuthGate's StreamBuilder swaps this screen out
      // automatically — no navigation call needed here.
    } on AuthCancelledException {
      // User backed out of the account picker — nothing to show.
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
    }
  }

  void _continueWithEmail() {
    setState(() => _errorText = null);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.storefront_rounded, size: 40, color: AppColors.primary),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          'Sign in to keep buying and selling.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        if (_errorText != null) ...[
                          Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.errorText,
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                        ],
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: _googleSubmitting ? null : _continueWithEmail,
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Continue with Email', style: AppTextStyles.button),
                          ),
                        ),
                        const OrDivider(),
                        GoogleSignInButton(
                          loading: _googleSubmitting,
                          onPressed: _googleSubmitting ? null : _signInWithGoogle,
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            GestureDetector(
                              onTap: _googleSubmitting
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SignupScreen(),
                                        ),
                                      ),
                              child: Text('Sign up', style: AppTextStyles.link),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
