import 'dart:ui';
import 'package:flutter/foundation.dart';
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
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {

    final mediaQueryTop = MediaQuery.of(context).padding.top;
    final topPadding = mediaQueryTop > 0 ? mediaQueryTop : (kIsWeb ? 0.0 : 47.0);
    //final canPop = Navigator.of(context).canPop();

    Widget? effectiveLeading = leading;
    //if (effectiveLeading == null && automaticallyImplyLeading && canPop) {
      //effectiveLeading = IconButton(
        // icon: const Icon(Icons.arrow_back_ios_new_rounded),
        // color: AppColors.textPrimary(context),
        // onPressed: () => Navigator.of(context).pop(),
      //);
    //}

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Title Center
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: Text(
                        title,
                        textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // Back Button
                if (effectiveLeading != null)
                  Positioned(
                    left: 0,
                    child: effectiveLeading,
                  ),

                // Action Buttons
                if (actions != null)
                  Positioned(
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ),
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