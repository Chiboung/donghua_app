import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final canPop = Navigator.of(context).canPop();

    // បង្កើត Back Button ដោយស្វ័យប្រវត្តិ ប្រសិនបើអាច Pop ត្រឡប់ក្រោយបាន
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && automaticallyImplyLeading && canPop) {
      effectiveLeading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.textPrimary(context),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.glassBlur,
            sigmaY: AppDimensions.glassBlur,
          ),
          child: Container(
            padding: EdgeInsets.only(
              top: topPadding,
              left: AppDimensions.paddingS,
              right: AppDimensions.paddingS,
            ),
            height: kToolbarHeight + topPadding,
            decoration: BoxDecoration(
              color: AppColors.glassFill(context),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.glassBorder(context),
                  width: AppDimensions.glassBorderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                if (effectiveLeading != null) effectiveLeading,
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50);
}