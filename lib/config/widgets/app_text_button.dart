import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// How an [AppTextButton] renders.
enum AppTextButtonVariant {
  /// A bare text link — inherits the app's global [TextButtonTheme]
  /// (primary-colored text, no background). Use for inline actions like
  /// "Forgot password?" or dialog actions ("Cancel", "Log out").
  plain,

  /// A rounded pill with a soft glass fill and hairline border — use
  /// for secondary, low-emphasis actions that should still read as a
  /// tappable chip, like "Show more" / "Show less".
  pill,
}

/// The app's single text-button widget, used everywhere a [TextButton]
/// would otherwise be reached for — dialog actions, inline links, and
/// pill-style toggles — so every text button in the app shares the same
/// padding, tap target, ripple, and color logic instead of each screen
/// re-styling its own.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppTextButtonVariant variant;

  /// Optional leading icon (e.g. a chevron for an expand/collapse toggle).
  final IconData? icon;

  /// Overrides the button's color. Defaults to the app's primary color
  /// for [AppTextButtonVariant.plain] and a neutral gray for
  /// [AppTextButtonVariant.pill].
  final Color? color;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppTextButtonVariant.plain,
    this.icon,
    this.color,
  });

  /// Convenience constructor for a "Show more" / "Show less" style pill.
  const AppTextButton.pill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  }) : variant = AppTextButtonVariant.pill;

  @override
  Widget build(BuildContext context) {
    final isPill = variant == AppTextButtonVariant.pill;
    final foreground = color ?? (isPill ? AppColors.textSecondary(context) : null);

    // Plain buttons pass no style at all so they fall through to the
    // app-wide TextButtonTheme untouched, unless a custom color was given.
    final style = isPill
        ? TextButton.styleFrom(
            foregroundColor: foreground,
            overlayColor: foreground,
            backgroundColor: AppColors.glassFill(context),
            side: BorderSide(color: AppColors.glassBorder(context)),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingXS,
            ),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        : (foreground != null ? TextButton.styleFrom(foregroundColor: foreground) : null);

    if (icon != null) {
      return TextButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
      );
    }
    return TextButton(style: style, onPressed: onPressed, child: Text(label));
  }
}
