import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding,
            left: AppDimensions.paddingS,
            right: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.glassFill(context),
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder(context),
                width: 0.5,
              ),
            ),
          ),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                if (canPop)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: AppColors.onCanvas(context),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.onCanvas(context),
                    ),
                  ),
                ),
                if (actions != null) Row(children: actions!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}