import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/app_background.dart';
import '../../../config/widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../widgets/google_sign_in_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  bool _googleSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final email = _emailController.text.trim();
      await AuthService.instance.signUp(
        email: email,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
      // signUp() sends a verification email and signs the new account
      // back out, so AuthGate keeps showing the login flow. Let the
      // user know to verify before they try logging in, then pop back.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created! We sent a verification link to $email — verify it, then log in.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleSubmitting = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();
      // Google sign-in creates the Firebase account on first use, so
      // this doubles as "sign up with Google" — just pop back to
      // AuthGate like the email/password flow does.
      if (mounted) Navigator.of(context).pop();
    } on AuthCancelledException {
      // User backed out of the account picker — nothing to show.
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
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
                              Text(
                                'Create your account',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.paddingXS),
                              Text(
                                'Start project donghua list run by zhiwenyi.',
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
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
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
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.newPassword],
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
                                  if (v == null || v.isEmpty) return 'Enter a password';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.newPassword],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: const InputDecoration(
                                  labelText: 'Confirm password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  if (v != _passwordController.text) {
                                    return 'Passwords don\'t match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.paddingL),
                              SizedBox(
                                height: AppDimensions.buttonHeight,
                                child: ElevatedButton(
                                  onPressed:
                                      (_submitting || _googleSubmitting) ? null : _submit,
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Sign up', style: AppTextStyles.button),
                                ),
                              ),
                              const OrDivider(),
                              GoogleSignInButton(
                                label: 'Sign up with Google',
                                loading: _googleSubmitting,
                                onPressed: (_submitting || _googleSubmitting)
                                    ? null
                                    : _signInWithGoogle,
                              ),
                              const SizedBox(height: AppDimensions.paddingM),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (_submitting || _googleSubmitting)
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    child: Text('Log in', style: AppTextStyles.link),
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
                    onPressed:
                        (_submitting || _googleSubmitting) ? null : () => Navigator.of(context).pop(),
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
