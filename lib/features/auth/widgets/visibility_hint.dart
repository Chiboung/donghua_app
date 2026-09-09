import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../services/user_service.dart';

/// Shows whether the entry being created will be public or private.
/// For an admin, it's also a toggle: tapping it flips [isPublicOverride]
/// between "visible to everyone" and "only visible to you" for this
/// entry specifically — a regular user's entries stay private and
/// can't be changed here.
///
/// Shared by every "add a new ___" screen (products, items, ...) so
/// the rule and its wording live in exactly one place.
class VisibilityHint extends StatelessWidget {
  final String? uid;
  final bool? isPublicOverride;
  final ValueChanged<bool> onChanged;

  const VisibilityHint({
    super.key,
    required this.uid,
    required this.isPublicOverride,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<UserRole>(
      stream: UserService.instance.watchRole(uid!),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.user;
        final isAdmin = role == UserRole.admin;
        final isPublic = isPublicOverride ?? isAdmin;
        final color = isPublic ? AppColors.success : AppColors.primary;
        final radius = BorderRadius.circular(AppDimensions.radiusS);

        return Material(
          color: color.withValues(alpha: 0.12),
          borderRadius: radius,
          child: InkWell(
            onTap: isAdmin ? () => onChanged(!isPublic) : null,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingS,
                vertical: AppDimensions.paddingXS,
              ),
              child: Row(
                children: [
                  Icon(
                    isPublic ? Icons.public : Icons.lock_outline,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Expanded(
                    child: Text(
                      isPublic
                          ? 'Visible to everyone once added.'
                          : 'Only visible to you once added.',
                      style: AppTextStyles.bodyMedium.copyWith(color: color),
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      'Change',
                      style: AppTextStyles.bodySmall.copyWith(color: color),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
