import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2);

  static const TextStyle h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2);

  static const TextStyle heading2 = h2;

  static const TextStyle h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);

  static const TextStyle bodyLarge = TextStyle(fontSize: 16, height: 1.4);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14, height: 1.4);

  static const TextStyle body = bodyMedium;

  static const TextStyle bodySmall = TextStyle(fontSize: 12, height: 1.3);

  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static const TextStyle errorText = TextStyle(fontSize: 13, color: AppColors.error);

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle h2Dynamic(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.3);
    return h2.copyWith(fontSize: h2.fontSize! * scale);
  }
}
