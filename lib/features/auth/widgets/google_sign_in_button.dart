import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';

/// The four-color Google "G" mark, drawn locally so the button doesn't
/// depend on a bundled asset or a network image.
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Four arcs, each roughly a quarter turn, in Google's brand colors.
    paint.color = const Color(0xFF4285F4); // blue
    canvas.drawArc(rect, -0.35, 1.62, false, paint);

    paint.color = const Color(0xFF34A853); // green
    canvas.drawArc(rect, 1.27, 1.62, false, paint);

    paint.color = const Color(0xFFFBBC05); // yellow
    canvas.drawArc(rect, 2.89, 1.0, false, paint);

    paint.color = const Color(0xFFEA4335); // red
    canvas.drawArc(rect, 3.89, 1.62, false, paint);

    // Crossbar of the "G".
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeWidth / 2,
        radius - strokeWidth * 0.15,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Continue with Google" button in Google's recommended neutral style —
/// kept white/outlined regardless of app theme, per Google's branding
/// guidelines for sign-in buttons.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFF4285F4),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogo(size: 20),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(color: const Color(0xFF1F1F1F)),
                  ),
                ],
              ),
      ),
    );
  }
}

/// "──── or ────" divider used between the email form and social buttons.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border(context))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
            child: Text(
              'or',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border(context))),
        ],
      ),
    );
  }
}
