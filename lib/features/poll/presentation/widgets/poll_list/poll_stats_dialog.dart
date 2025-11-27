import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/poll/data/models/poll_stats_response.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_bloc.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_event.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PollStatsDialog extends StatelessWidget {
  const PollStatsDialog({
    required this.pollId,
    required this.eventId,
    super.key,
  });

  final int pollId;
  final int eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<PollStatsBloc>()..add(PollStatsFetched(eventId)),
      child: BlocBuilder<PollStatsBloc, PollStatsState>(
        builder: (context, state) {
          PollStatsResponse? pollStats;
          if (state is PollStatsSuccess) {
            pollStats = state.stats.firstWhere(
              (s) => s.id == pollId,
              orElse: () => state.stats.first,
            );
          }

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: AppColors.vkuBlue),
                const SizedBox(width: AppSpacing.spaceXS),
                const Text('Thống kê Poll'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: state is PollStatsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is PollStatsError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.red500,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),
                        Text(state.message, textAlign: TextAlign.center),
                      ],
                    )
                  : pollStats == null
                  ? const Text('Không tìm thấy thống kê')
                  : Builder(
                      builder: (context) {
                        final stats = pollStats!;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(stats.title, style: AppTextStyles.heading4),
                              const SizedBox(height: AppSpacing.spaceMD),
                              Row(
                                children: [
                                  _StatCard(
                                    icon: Icons.people,
                                    label: 'Người bỏ phiếu',
                                    value: '${stats.totalVoters}',
                                  ),
                                  const SizedBox(width: AppSpacing.spaceMD),
                                  _StatCard(
                                    icon: Icons.how_to_vote,
                                    label: 'Tổng số phiếu',
                                    value: '${stats.totalVotes}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.spaceLG),
                              const Divider(),
                              const SizedBox(height: AppSpacing.spaceMD),
                              Text('Kết quả:', style: AppTextStyles.heading5),
                              const SizedBox(height: AppSpacing.spaceMD),
                              ...stats.options.map((option) {
                                final totalVotes = stats.totalVotes;
                                final percentage = totalVotes > 0
                                    ? (option.voteCount / totalVotes * 100)
                                          .toStringAsFixed(1)
                                    : '0.0';
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.spaceMD,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option.text,
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                          ),
                                          Text(
                                            '$percentage%',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: AppSpacing.spaceXS,
                                      ),
                                      LinearProgressIndicator(
                                        value: totalVotes > 0
                                            ? option.voteCount / totalVotes
                                            : 0,
                                        backgroundColor: AppColors.coolGray50,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.vkuBlue,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${option.voteCount} phiếu',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.coolGray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.blue50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.vkuBlue, size: 24),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(color: AppColors.vkuBlue),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
