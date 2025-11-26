import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/check_in_history/check_in_history_bloc.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/check_in_history/check_in_history_event.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/check_in_history/check_in_history_state.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/check_in_history_section.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CheckInHistoryBloc>()
        ..add(
          CheckInHistoryInitialize(
            eventId: eventDetail.id,
            participants: eventDetail.participants,
          ),
        ),
      child: BlocBuilder<CheckInHistoryBloc, CheckInHistoryState>(
        builder: (context, checkInState) {
          // Lấy statistics từ CheckInHistoryBloc state nếu có, ngược lại dùng từ eventDetail
          final checkedInCount = checkInState is CheckInHistorySuccess
              ? checkInState.checkedInCount
              : eventDetail.participants
                    .where((p) => p.isCheckedIn ?? false)
                    .length;

          final totalParticipants = checkInState is CheckInHistorySuccess
              ? checkInState.totalParticipants
              : eventDetail.participants.length;

          final notCheckedInCount = totalParticipants - checkedInCount;
          final checkInRate = totalParticipants > 0
              ? checkedInCount / totalParticipants
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Đã check-in',
                        value: '$checkedInCount',
                        total: '/ $totalParticipants',
                        progress: checkInRate,
                        gradient: AppColors.primaryGradient,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceMD),
                    Expanded(
                      child: StatCard(
                        title: 'Chưa check-in',
                        value: '$notCheckedInCount',
                        progress: totalParticipants > 0
                            ? notCheckedInCount / totalParticipants
                            : 0.0,
                        gradient: AppColors.secondaryGradient,
                        icon: Icons.pending_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                StatCard(
                  title: 'Tỷ lệ check-in',
                  value: '${(checkInRate * 100).toStringAsFixed(1)}%',
                  progress: checkInRate,
                  gradient: AppColors.accentGradient,
                  icon: Icons.trending_up_rounded,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.spaceLG),

                // Real-time Check-in History Section
                // Sử dụng BlocProvider.value để share cùng CheckInHistoryBloc
                BlocProvider.value(
                  value: context.read<CheckInHistoryBloc>(),
                  child: CheckInHistorySection(eventDetail: eventDetail),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
