import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
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
        content: const Text('You\'ll need to sign in again to buy or sell.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
      backgroundColor: Colors.transparent,
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
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.person, size: 40, color: Colors.white),
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
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      _ProfileTile(
                        icon: Icons.logout,
                        label: 'Log out',
                        color: AppColors.error,
                        onTap: () => _confirmLogOut(context),
                      ),
                    ],
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
      onTap: onTap ?? () {},
    );
  }
}