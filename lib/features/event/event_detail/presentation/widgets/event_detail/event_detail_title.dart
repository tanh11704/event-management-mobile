import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventDetailTitle extends StatelessWidget {
  const EventDetailTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading1.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 26,
        height: 1.3,
        letterSpacing: -0.5,
      ),
    );
  }
}
