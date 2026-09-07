import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../auth/services/auth_service.dart';
import '../../home/models/product.dart';
import '../../home/screens/product_detail_screen.dart';
import '../../home/services/product_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'My List'),
      body: StreamBuilder<List<Product>>(
        stream: ProductService.instance.watchVisibleProducts(uid),
        builder: (context, snapshot) {
          final cartItems = (snapshot.data ?? const <Product>[]).take(100).toList();

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cartItems.isEmpty) {
            return Center(
              child: Text(
                'Your list is empty.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.paddingS),
                    itemBuilder: (context, index) {
                      final product = cartItems[index];
                      return GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingS,
                          vertical: AppDimensions.paddingXS,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            backgroundImage: product.imageUrl.isNotEmpty
                                ? NetworkImage(product.imageUrl)
                                : null,
                            child: product.imageUrl.isEmpty
                                ? Icon(Icons.shopping_bag_outlined, color: AppColors.primary)
                                : null,
                          ),
                          title: Text(
                            product.titleKh,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.textPrimary(context)),
                          ),
                          subtitle: Text(
                            product.episodeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
