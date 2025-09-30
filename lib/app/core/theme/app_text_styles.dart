// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';

class AppTextStyles {
  static const HEADING_1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const HEADING_2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const HEADING_3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  static const HEADING_4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static const HEADING_5 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

  static const BODY_LARGE = TextStyle(fontSize: 16, height: 1.5);

  static const BODY_MEDIUM = TextStyle(fontSize: 14, height: 1.4);

  static const BODY_SMALL = TextStyle(fontSize: 12, height: 1.5);

  static const CAPTION = TextStyle(fontSize: 10, height: 1.4);
}
