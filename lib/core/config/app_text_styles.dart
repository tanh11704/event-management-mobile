import 'package:event_management/core/config/app_colors.dart';
import 'package:flutter/cupertino.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.coolGray900,
  );

  static final TextStyle heading1 = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  static final TextStyle heading2 = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );
  static final TextStyle heading3 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle heading4 = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle heading5 = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    height: 1.5,
    color: AppColors.coolGray500,
  );
  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    height: 1.4,
    color: AppColors.coolGray500,
  );
  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    height: 1.5,
    color: AppColors.coolGray500,
  );

  static final TextStyle caption = _base.copyWith(
    fontSize: 10,
    height: 1.4,
    color: AppColors.coolGray500,
  );
}
