import 'package:flutter/rendering.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color vkuBlue = Color(0xFF1D4ED8);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue400 = Color(0xFF60A5FA);

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [vkuBlue, blue400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary
  static const amber400 = Color(0xFFFBBF24);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber600 = Color(0xFFD97706);
  static const amber800 = Color(0xFF92400E);

  static LinearGradient get secondaryGradient => const LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFFEF3C7)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  // ACCENT
  static const red500 = Color(0xFFEF4444);
  static const red100 = Color(0xFFFEE2E2);
  static const red800 = Color(0xFF991B1B);

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFFEE2E2)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  // System
  static const green500 = Color(0xFF10B981);
  static const green50 = Color(0xFFECFDF5);
  static const green800 = Color(0xFF065F46);

  // Neural
  static const white = Color(0xFFFFFFFF);
  static const coolGray50 = Color(0xFFF9FAFB);
  static const coolGray500 = Color(0xFF6B7280);
  static const coolGray700 = Color(0xFF374151);
  static const coolGray900 = Color(0xFF111827);
  static const border = Color(0xFFD1D5DB);

  // BACKGROUND
  static LinearGradient get background => const LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );
}
