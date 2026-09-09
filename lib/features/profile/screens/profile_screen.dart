import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/app_text_button.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text("You'll need to sign in again to donghua."),
      actions: [
        AppTextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          label: 'Cancel',
        ),
        AppTextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          label: 'Log out',
          color: AppColors.error,
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // 1. Pop all routes on top of AuthGate FIRST
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

    // 2. Perform sign out to trigger AuthGate rebuild
    await AuthService.instance.signOut();
  }
}

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : 'Your Profile';
    final email = user?.email ?? '';

    return Scaffold(
      body: Column(
        children: [
          const GlassAppBar(title: 'Profile'),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                110,
              ),
              children: [
                GlassContainer(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: AppDimensions.avatarSize / 2,
                        backgroundColor: AppColors.textSecondary(context),
                        child: Icon(Icons.person, size: 50, color: AppColors.textPrimary(context)),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        displayName,
                        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary(context)),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          email,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const _ProfileTile(icon: Icons.list_alt, label: 'My Listings'),
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      const _ProfileTile(icon: Icons.favorite_border, label: 'Favorites'),
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      const _ProfileTile(icon: Icons.settings_outlined, label: 'Settings'),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: _ProfileTile(
                    icon: Icons.logout,
                    label: 'Log out',
                    color: AppColors.error,
                    onTap: () => _confirmLogOut(context),
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ProfileTile({required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary(context);
    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(color: tileColor),
      ),
      trailing: color == null
          ? Icon(Icons.chevron_right, color: AppColors.textHint(context))
          : null,
      onTap: onTap,
    );
  }
}