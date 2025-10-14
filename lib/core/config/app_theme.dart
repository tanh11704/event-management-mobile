import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.vkuBlue,
    scaffoldBackgroundColor: AppColors.coolGray50,
    fontFamily: AppTextStyles.fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.vkuBlue,
      secondary: AppColors.amber400,
      error: AppColors.red500,
    ),
    textTheme:
        TextTheme(
          headlineLarge: AppTextStyles.heading1,
          headlineMedium: AppTextStyles.heading2,
          headlineSmall: AppTextStyles.heading3,
          titleLarge: AppTextStyles.heading4,
          titleMedium: AppTextStyles.heading5,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelSmall: AppTextStyles.caption,
        ).apply(
          bodyColor: AppColors.coolGray900,
          displayColor: AppColors.coolGray900,
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vkuBlue,
        foregroundColor: AppColors.white,
        textStyle: AppTextStyles.heading5.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.vkuBlue, width: 2),
      ),
    ),
  );
}
