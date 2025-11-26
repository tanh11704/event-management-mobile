import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_state.dart'; // Import state
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventCardJoinButton extends StatelessWidget {
  const EventCardJoinButton({required this.event, super.key});

  final Event event;

  bool get _canJoin {
    if (event.isRegistered ?? false) return false;
    if (event.status != EventStatus.upcoming) return false;
    if (event.qrJoinToken == null || event.qrJoinToken!.isEmpty) return false;
    if (event.maxParticipants != null &&
        event.currentParticipants != null &&
        event.currentParticipants! >= event.maxParticipants!) {
      return false;
    }
    return true;
  }

  String? get _disabledReason {
    if (event.isRegistered ?? false) return 'Bạn đã tham gia sự kiện này';
    if (event.status != EventStatus.upcoming)
      return 'Sự kiện không còn khả dụng';
    if (event.qrJoinToken == null || event.qrJoinToken!.isEmpty) {
      return 'Không có mã tham gia';
    }
    if (event.maxParticipants != null &&
        event.currentParticipants != null &&
        event.currentParticipants! >= event.maxParticipants!) {
      return 'Sự kiện đã đầy';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_canJoin) {
      return Tooltip(
        message: _disabledReason ?? 'Không thể tham gia',
        child: IconButton(
          onPressed: null,
          icon: Icon(
            event.isRegistered ?? false
                ? Icons.check_circle_rounded
                : Icons.block_rounded,
            size: 20,
            color: AppColors.coolGray500,
          ),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      );
    }

    return BlocBuilder<EventListBloc, EventListState>(
      buildWhen: (previous, current) {
        if (current is EventListLoading) return true;
        if (previous is EventListLoading &&
            previous.joiningEventToken == event.qrJoinToken) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        final isLoading =
            state is EventListLoading &&
            state.joiningEventToken == event.qrJoinToken;

        return Tooltip(
          message: isLoading ? 'Đang tham gia...' : 'Tham gia sự kiện',
          child: IconButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<EventListBloc>().add(
                      EventListJoinEvent(eventToken: event.qrJoinToken!),
                    );
                  },
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_add_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
            iconSize: 20,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.vkuBlue,
              disabledBackgroundColor: AppColors.coolGray500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
