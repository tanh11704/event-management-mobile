import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/check_in_history_item.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/stat_card.dart';
import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  int get _checkedInCount {
    return eventDetail.participants.where((p) => p.isCheckedIn ?? false).length;
  }

  int get _notCheckedInCount {
    return eventDetail.participants.where((p) => p.isCheckedIn != true).length;
  }

  int get _totalParticipants {
    return eventDetail.participants.length;
  }

  double get _checkInRate {
    if (_totalParticipants == 0) return 0;
    return _checkedInCount / _totalParticipants;
  }

  List<ParticipantInfo> get _recentCheckIns {
    final checkedIn = eventDetail.participants
        .where((p) => (p.isCheckedIn ?? false) && p.checkedTime != null)
        .toList();
    checkedIn.sort((a, b) {
      if (a.checkedTime == null || b.checkedTime == null) return 0;
      return b.checkedTime!.compareTo(a.checkedTime!);
    });
    return checkedIn;
  }

  @override
  Widget build(BuildContext context) {
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
                  value: '$_checkedInCount',
                  total: '/ $_totalParticipants',
                  progress: _checkInRate,
                  gradient: AppColors.primaryGradient,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Expanded(
                child: StatCard(
                  title: 'Chưa check-in',
                  value: '$_notCheckedInCount',
                  progress: _totalParticipants > 0
                      ? _notCheckedInCount / _totalParticipants
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
            value: '${(_checkInRate * 100).toStringAsFixed(1)}%',
            progress: _checkInRate,
            gradient: AppColors.accentGradient,
            icon: Icons.trending_up_rounded,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.spaceLG),

          // Real-time Check-in History
          Row(
            children: [
              const Icon(
                Icons.rss_feed_rounded,
                color: AppColors.green500,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.spaceXS),
              Text(
                'Lịch sử check-in (Real-time)',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Container(
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
            child: _recentCheckIns.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.spaceLG),
                    child: Center(
                      child: Text(
                        'Chưa có lịch sử check-in',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentCheckIns.length > 10
                        ? 10
                        : _recentCheckIns.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: AppSpacing.spaceMD,
                      endIndent: AppSpacing.spaceMD,
                    ),
                    itemBuilder: (context, index) {
                      final participant = _recentCheckIns[index];
                      return CheckInHistoryItem(
                        participant: participant,
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
