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
  // Variable សម្រាប់គ្រប់គ្រង Mode កំពុង Edit ឬអត់
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'My List',
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit_outlined,
              color: AppColors.textPrimary(context),
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing; // ប្ដូរ Mode ពេលចុច
              });
            },
          ),
        ],
      ),
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

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.paddingM,
                    left: AppDimensions.paddingM,
                    right: AppDimensions.paddingM,
                    bottom: 100, // ផុតពី Bottom Nav Bar
                  ),
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
                        trailing: _isEditing
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {
                                  // ដាក់ Logic លុប Item នៅទីនេះ (ឧទាហរណ៍៖ លុបចេញពី Database)
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}