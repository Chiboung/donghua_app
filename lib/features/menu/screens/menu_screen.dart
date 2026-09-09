import 'package:flutter/material.dart';
import '../../../config/app_info.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
//import '../../../config/widgets/app_text_button.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../add/screens/add_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../items/screens/add_item_screen.dart';
import '../../mylist/screens/mylist_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'about_screen.dart';

/// The "Menu" tab — a hub of everything that isn't Home/Categories/Add:
/// account (Profile), listings, and sign-out.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // Future<void> _confirmLogOut(BuildContext context) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       title: const Text('Log out?'),
  //       content: const Text('You\'ll need to sign in again to buy or sell.'),
  //       actions: [
  //         AppTextButton(
  //           onPressed: () => Navigator.of(dialogContext).pop(false),
  //           label: 'Cancel',
  //         ),
  //         AppTextButton(
  //           onPressed: () => Navigator.of(dialogContext).pop(true),
  //           label: 'Log out',
  //           color: AppColors.error,
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true) {
  //     await AuthService.instance.signOut();
  //     if (context.mounted) {
  //       Navigator.of(context).popUntil((route) => route.isFirst);
  //     }
  //   }
  // }

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
          const GlassAppBar(title: 'Menu'),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                110, // clears the floating bottom nav bar
              ),
              children: [
                // Tapping this row is the "button click to profile screen".
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: GlassContainer(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: AppDimensions.avatarSize / 2 - 8,
                            backgroundColor: AppColors.textSecondary(context),
                            child: Icon(Icons.person, color: AppColors.textPrimary(context), size: 40,),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textHint(context)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.list_alt_outlined,
                        label: 'My Listings',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MyListScreen()),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      _MenuTile(
                        icon: Icons.add_circle_outline,
                        label: 'Add Entry',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddScreen()),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      _MenuTile(
                        icon: Icons.storefront_outlined,
                        label: 'Add Item',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddItemScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: _MenuTile(
                    icon: Icons.info_outline,
                    label: 'About App',
                    color: AppColors.textPrimary(context),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                ),
                // const SizedBox(height: AppDimensions.paddingM),
                // GlassContainer(
                //   padding: EdgeInsets.zero,
                //   child: _MenuTile(
                //     icon: Icons.logout,
                //     label: 'Log out',
                //     color: AppColors.textPrimary(context),
                //     onTap: () => _confirmLogOut(context),
                //   ),
                // ),
                const SizedBox(height: AppDimensions.paddingL),
                Center(
                  child: Text(
                    'Version ${AppInfo.version} ${AppInfo.buildNumber}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textHint(context)),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuTile({required this.icon, required this.label, this.color, this.onTap});

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

