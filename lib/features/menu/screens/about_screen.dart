import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_info.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: AppInfo.supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const GlassAppBar(title: 'About'),
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
                GlassContainer(
                  child: Column(
                    children: [
                      Container(
                        width: AppDimensions.avatarSize,
                        height: AppDimensions.avatarSize,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary(context),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                        child: const Icon(
                          Icons.local_movies_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        AppInfo.appName,
                        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary(context)),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        'Version ${AppInfo.version} ${AppInfo.buildNumber}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        AppInfo.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _InfoTile2(
                        icon: Icons.info_outline,
                        label: 'Version',
                        value: '${AppInfo.version} ${AppInfo.buildNumber}',
                        onTap: () {},
                      ),
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      _InfoTile2(
                        icon: Icons.groups_outlined,
                        label: 'Developer',
                        value: AppInfo.developer,
                        onTap: () {},
                      ),
                      Divider(height: 1, color: AppColors.glassBorder(context)),
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Support',
                        value: AppInfo.supportEmail,
                        onTap: () => _copyEmail(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                Center(
                  child: Text(
                    '${AppInfo.made}',
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary(context)),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context)),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
      ),
      trailing: onTap != null
          ? Icon(Icons.copy, size: 18, color: AppColors.textHint(context))
          : null,
      onTap: onTap,
    );
  }
}

class _InfoTile2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile2({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary(context)),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context)),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
      ),
      // trailing: onTap != null
      //     ? Icon(Icons.chevron_right, size: 18, color: AppColors.textHint(context))
      //     : null,
      onTap: onTap,
    );
  }
}
