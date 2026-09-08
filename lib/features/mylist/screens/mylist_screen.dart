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

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GlassAppBar(
            title: 'My List',
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit_outlined,
                  color: AppColors.textPrimary(context),
                ),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
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
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingM,
                    AppDimensions.paddingM,
                    AppDimensions.paddingM,
                    110,
                  ),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingS),
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
                              ? const Icon(Icons.shopping_bag_outlined, color: AppColors.primary)
                              : null,
                        ),
                        title: Text(
                          product.titleKh,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context)),
                        ),
                        subtitle: Text(
                          product.episodeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                        ),
                        trailing: _isEditing
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {},
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}