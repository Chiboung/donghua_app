import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/app_background.dart';
import '../../../config/widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

/// Email/password sign-in form. Reached by tapping "Continue with Email"
/// on the [LoginScreen] chooser — kept as its own screen so the chooser
/// stays a simple, uncluttered pick between Email and Google.
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // AuthGate's StreamBuilder swaps its content to the home shell as
      // soon as the auth state changes, but that happens *underneath*
      // this screen — it was pushed on top of AuthGate's route, so it
      // has to pop itself off to actually reveal it.
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Enter your email above first, then tap "Forgot password?"');
      return;
    }
    try {
      await AuthService.instance.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    }
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
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_outlined, size: 36, color: AppColors.primary),
                              const SizedBox(height: AppDimensions.paddingS),
                              Text(
                                'Log in with email',
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
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                                  if (!v.contains('@') || !v.contains('.')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter your password';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _submitting ? null : _forgotPassword,
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              SizedBox(
                                height: AppDimensions.buttonHeight,
                                child: ElevatedButton(
                                  onPressed: _submitting ? null : _submit,
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Log in', style: AppTextStyles.button),
                                ),
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
                                    onTap: _submitting
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
                Positioned(
                  top: AppDimensions.paddingS,
                  left: AppDimensions.paddingS,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.onCanvas(context)),
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
