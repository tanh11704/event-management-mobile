import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/qr_code_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/secretary_management_section.dart';
import 'package:flutter/material.dart';

class ToolsSettingsTab extends StatelessWidget {
  const ToolsSettingsTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Section
          QrCodeSection(eventId: eventDetail.id),
          const SizedBox(height: AppSpacing.spaceLG),

          // Secretary Management Section
          SecretaryManagementSection(
            eventId: eventDetail.id,
            participants: eventDetail.participants,
          ),
        ],
      ),
    );
  }
}
