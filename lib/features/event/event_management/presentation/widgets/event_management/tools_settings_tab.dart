import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/qr_code_section.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/secretary_management_section.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/poll/presentation/widgets/create_poll/create_poll_section_button.dart';
import 'package:event_management/features/poll/presentation/widgets/poll_list/poll_list_section.dart';
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
          // Create Poll Section Button
          CreatePollSectionButton(eventId: eventDetail.id),
          const SizedBox(height: AppSpacing.spaceLG),

          // Poll List Section
          PollListSection(eventId: eventDetail.id),
          const SizedBox(height: AppSpacing.spaceLG),

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
