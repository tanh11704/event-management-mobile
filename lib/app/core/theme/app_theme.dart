import 'package:event_management/app/core/theme/app_colors.dart';
import 'package:event_management/app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.VKU_BLUE,
    scaffoldBackgroundColor: AppColors.COOL_GRAY_50,

    colorScheme: const ColorScheme.light(
      primary: AppColors.VKU_BLUE,
      secondary: AppColors.AMBER_400,
      error: AppColors.RED_500,
      surface: AppColors.BLUE_400,
    ),

    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.HEADING_1,
      headlineMedium: AppTextStyles.HEADING_2,
      headlineSmall: AppTextStyles.HEADING_3,
      titleLarge: AppTextStyles.HEADING_4,
      titleMedium: AppTextStyles.HEADING_5,
      bodyLarge: AppTextStyles.BODY_LARGE,
      bodyMedium: AppTextStyles.BODY_MEDIUM,
      bodySmall: AppTextStyles.BODY_SMALL,
      labelSmall: AppTextStyles.CAPTION,
    ),
  );
}
