import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_bloc.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_event.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDetailCtaButton extends StatelessWidget {
  const EventDetailCtaButton({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailBloc, EventDetailState>(
      buildWhen: (previous, current) {
        if (previous is EventDetailSuccess && current is EventDetailSuccess) {
          return previous.isJoining != current.isJoining;
        }
        return true;
      },
      builder: (context, state) {
        final isLoading = state is EventDetailSuccess && state.isJoining;

        final (text, backgroundColor, icon, isEnabled) = _getButtonConfig(
          eventDetail,
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.coolGray500.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.spaceMD,
              right: AppSpacing.spaceMD,
              top: AppSpacing.spaceMD,
              bottom:
                  AppSpacing.spaceMD + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isEnabled && !isLoading
                    ? () {
                        if (eventDetail.isUserRegistered ?? false) {
                          context.read<EventDetailBloc>().add(
                            EventDetailUnjoin(eventId: eventDetail.id),
                          );
                        } else {
                          context.read<EventDetailBloc>().add(
                            EventDetailJoin(
                              eventToken: eventDetail.qrJoinToken!,
                            ),
                          );
                        }
                      }
                    : null,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Icon(icon, size: 20),
                label: Text(
                  text,
                  style: AppTextStyles.heading5.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.coolGray500,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (String, Color, IconData, bool) _getButtonConfig(
    EventDetailResponse eventDetail,
  ) {
    if (eventDetail.status == EventStatus.completed ||
        eventDetail.status == EventStatus.cancelled) {
      return (
        'Sự kiện đã kết thúc',
        AppColors.coolGray500,
        Icons.check_circle_outline_rounded,
        false,
      );
    }

    if (eventDetail.status == EventStatus.upcoming ||
        eventDetail.status == EventStatus.ongoing) {
      if (eventDetail.isUserRegistered ?? false) {
        return (
          'Hủy tham gia',
          AppColors.red500,
          Icons.person_remove_rounded,
          true,
        );
      }

      final isFull =
          eventDetail.maxParticipants != null &&
          eventDetail.participants.length >= eventDetail.maxParticipants!;
      if (isFull) {
        return (
          'Sự kiện đã đầy',
          AppColors.coolGray500,
          Icons.block_rounded,
          false,
        );
      }

      if (eventDetail.qrJoinToken == null || eventDetail.qrJoinToken!.isEmpty) {
        return (
          'Không thể đăng ký',
          AppColors.coolGray500,
          Icons.block_rounded,
          false, // Disabled
        );
      }

      return (
        'Đăng ký tham gia',
        AppColors.vkuBlue,
        Icons.person_add_rounded,
        true, // Enabled
      );
    }

    return (
      'Không khả dụng',
      AppColors.coolGray500,
      Icons.block_rounded,
      false,
    );
  }
}
