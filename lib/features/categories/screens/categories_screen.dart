import 'package:flutter/material.dart';
import '../../../config/layouts/responsive_grid.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../auth/services/auth_service.dart';
import '../../items/models/item.dart';
import '../../items/models/item_type.dart';
import '../../items/screens/add_item_screen.dart';
import '../../items/screens/item_detail_screen.dart';
import '../../items/services/item_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  /// null means "All" — no type filter applied.
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;

    return Scaffold(
      //backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Glass Header
          GlassAppBar(
            title: 'Categories',
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: AppColors.textPrimary(context)),
                tooltip: 'Add item',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                ),
              ),
            ],
          ),

          // Category filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingXS,
              ),
              children: [
                _CategoryChip(
                  label: 'All',
                  icon: Icons.apps,
                  selected: _selectedType == null,
                  onTap: () => setState(() => _selectedType = null),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                for (var i = 0; i < ItemType.all.length; i++) ...[
                  _CategoryChip(
                    label: ItemType.all[i].name,
                    icon: ItemType.all[i].icon,
                    selected: _selectedType == ItemType.all[i].name,
                    onTap: () => setState(() {
                      _selectedType = _selectedType == ItemType.all[i].name
                          ? null
                          : ItemType.all[i].name;
                    }),
                  ),
                  if (i != ItemType.all.length - 1)
                    const SizedBox(width: AppDimensions.paddingS),
                ],
              ],
            ),
          ),

          // Main Scrollable Content — items, same layout as Home.
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: ItemService.instance.watchVisibleItems(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Text(
                        'Couldn\'t load items: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!
                    .where((item) => _selectedType == null || item.type == _selectedType)
                    .toList();

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedType == null
                          ? 'No items yet — be the first to add something!'
                          : 'No items in "$_selectedType" yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary(context)),
                    ),
                  );
                }

                return ResponsiveProductGrid(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingM,
                    AppDimensions.paddingM,
                    AppDimensions.paddingM,
                    110, // clears the floating bottom nav bar
                  ),
                  itemCount: items.length,
                  imageAspectRatio: 4 / 3,
                  fixedContentExtent: 90,
                  itemBuilder: (context, index) => _ItemCard(item: items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary(context) : AppColors.textSecondary(context);
    return Material(
      color: selected
          ? AppColors.textPrimary(context).withValues(alpha: 0.12)
          : AppColors.glassFill(context),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingXS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: selected ? AppColors.textPrimary(context) : AppColors.glassBorder(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppDimensions.paddingXS),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
      ),
      child: GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusL),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textHint(context),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.textHint(context),
                          ),
                        ),
                  if (item.hasDiscount)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Text(
                          '-${item.discount.toStringAsFixed(0)}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  item.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Row(
                  children: [
                    Text(
                      '\$${item.finalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint(context),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
