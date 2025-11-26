import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/check_in_history/check_in_history_bloc.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/check_in_history/check_in_history_event.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/check_in_history/check_in_history_state.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/check_in_history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInHistorySection extends StatefulWidget {
  const CheckInHistorySection({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  State<CheckInHistorySection> createState() => _CheckInHistorySectionState();
}

class _CheckInHistorySectionState extends State<CheckInHistorySection> {
  CheckInHistoryBloc? _bloc;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đã có CheckInHistoryBloc trong context chưa
    // Nếu có thì dùng, nếu không thì tạo mới
    CheckInHistoryBloc? existingBloc;
    try {
      existingBloc = context.read<CheckInHistoryBloc>();
    } catch (_) {
      // Bloc chưa có trong context, sẽ tạo mới
    }

    // Nếu có bloc sẵn từ context (được share từ OverviewTab), sử dụng nó
    if (existingBloc != null) {
      _bloc = existingBloc;
      return BlocBuilder<CheckInHistoryBloc, CheckInHistoryState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildStatisticsCard(state),
              const SizedBox(height: AppSpacing.spaceLG),

              // Header
              Row(
                children: [
                  const Icon(
                    Icons.rss_feed_rounded,
                    color: AppColors.green500,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spaceXS),
                  Text(
                    'Lịch sử Check-in (Real-time)',
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(width: AppSpacing.spaceXS),
                  if (state is CheckInHistorySuccess && state.isConnected)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.green500,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Check-in History List
              _buildCheckInHistoryList(state),
            ],
          );
        },
      );
    }

    // Nếu không có bloc sẵn, tạo mới
    _bloc = di.sl<CheckInHistoryBloc>()
      ..add(
        CheckInHistoryInitialize(
          eventId: widget.eventDetail.id,
          participants: widget.eventDetail.participants,
        ),
      );

    return BlocProvider(
      create: (context) => _bloc!,
      child: BlocBuilder<CheckInHistoryBloc, CheckInHistoryState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildStatisticsCard(state),
              const SizedBox(height: AppSpacing.spaceLG),

              // Header
              Row(
                children: [
                  const Icon(
                    Icons.rss_feed_rounded,
                    color: AppColors.green500,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.spaceXS),
                  Text(
                    'Lịch sử Check-in (Real-time)',
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(width: AppSpacing.spaceXS),
                  if (state is CheckInHistorySuccess && state.isConnected)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.green500,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMD),

              // Check-in History List
              _buildCheckInHistoryList(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(CheckInHistoryState state) {
    if (state is! CheckInHistorySuccess) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray900.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.green500,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.spaceMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đã check-in',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.coolGray500,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXS),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.coolGray900,
                  ),
                  children: [
                    TextSpan(
                      text: '${state.checkedInCount}',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.green500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${state.totalParticipants}',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.coolGray700,
                      ),
                    ),
                    TextSpan(
                      text: ' người tham gia',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.coolGray700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInHistoryList(CheckInHistoryState state) {
    if (state is CheckInHistoryLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.coolGray900.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is CheckInHistoryError) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.coolGray900.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.red500,
              ),
              const SizedBox(height: AppSpacing.spaceMD),
              Text(
                state.error,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceMD),
              ElevatedButton(
                onPressed: () {
                  context.read<CheckInHistoryBloc>().add(
                    CheckInHistoryRefresh(eventId: widget.eventDetail.id),
                  );
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CheckInHistorySuccess) {
      if (state.checkInHistory.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.coolGray900.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: AppColors.coolGray500,
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                Text(
                  'Chưa có lịch sử check-in',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.coolGray900.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.checkInHistory.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: AppSpacing.spaceMD,
            endIndent: AppSpacing.spaceMD,
          ),
          itemBuilder: (context, index) {
            final participant = state.checkInHistory[index];
            return CheckInHistoryItem(participant: participant, index: index);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
