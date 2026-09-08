import 'package:flutter/material.dart';
import '../../../config/layouts/responsive_grid.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../auth/services/auth_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Glass Header ហូរឡើងទៅគ្របលើ Status Bar
          const GlassAppBar(title: 'Home'),

          // Main Scroll Content
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: ProductService.instance.watchVisibleProducts(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Text(
                        'Couldn\'t load listings: ${snapshot.error}',
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

                final products = snapshot.data!;
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No listings yet — be the first to add something!',
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
                    110, // លំហែសម្រាប់ Floating Nav Bar ខាងក្រោម
                  ),
                  itemCount: products.length,
                  imageAspectRatio: 2 / 3,
                  fixedContentExtent: 100,
                  itemBuilder: (context, index) => _ProductCard(product: products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusL),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.titleKh,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    product.titleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    product.episodeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
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