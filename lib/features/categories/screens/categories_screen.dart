import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';

/// Categories tab: browse listings grouped by category.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<_Category> _categories = [
    _Category('Electronics', Icons.devices_other),
    _Category('Fashion', Icons.checkroom),
    _Category('Home & Garden', Icons.chair_outlined),
    _Category('Sports', Icons.sports_basketball_outlined),
    _Category('Toys', Icons.toys_outlined),
    _Category('Books', Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Categories'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingM,
          AppDimensions.paddingM,
          AppDimensions.paddingM,
          96,
        ),
        children: [
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _categories.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: AppColors.glassBorder(context)),
                  ListTile(
                    leading: Icon(_categories[i].icon, color: AppColors.primary),
                    title: Text(
                      _categories[i].name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: AppColors.textHint(context)),
                    onTap: () {},
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String name;
  final IconData icon;

  const _Category(this.name, this.icon);
}
