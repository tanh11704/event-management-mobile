import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EditEventSectionHeader extends StatelessWidget {
  const EditEventSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.spaceLG,
        bottom: AppSpacing.spaceXS,
        left: 4,
      ),
      child: Text(
        title,
        style: AppTextStyles.heading5.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
