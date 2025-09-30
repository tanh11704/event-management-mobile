import 'package:flutter/rendering.dart';

class AppColors {
  // Primary
  static const VKU_BLUE = Color(0xFF1D4ED8);
  static const BLUE_50 = Color(0xFFEFF6FF);
  static const BLUE_400 = Color(0xFFDBEAFE);

  static const PRIMARY_GRADIENT = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  // Secondary
  static const AMBER_400 = Color(0xFFFBBF24);
  static const AMBER_100 = Color(0xFFFEF3C7);
  static const AMBER_600 = Color(0xFFD97706);
  static const AMBER_800 = Color(0xFF92400E);

  static const SECONDARY_GRADIENT = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFFEF3C7)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  // ACCENT
  static const RED_500 = Color(0xFFEF4444);
  static const RED_100 = Color(0xFFFEE2E2);
  static const RED_800 = Color(0xFF991B1B);

  static const ACCENT_GRADIENT = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFFEE2E2)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  // System
  static const GREEN_500 = Color(0xFF10B981);
  static const GREEN_50 = Color(0xFFECFDF5);
  static const GREEN_800 = Color(0xFF065F46);

  // Neural
  static const WHITE = Color(0xFFFFFFFF);
  static const COOL_GRAY_50 = Color(0xFFF9FAFB);
  static const COOL_GRAY_500 = Color(0xFF6B7280);
  static const COOL_GRAY_700 = Color(0xFF374151);
  static const COOL_GRAY_900 = Color(0xFF111827);
  static const BORDER = Color(0xFFD1D5DB);

  // BACKGROUND
  static const BACKGROUND = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );
}
