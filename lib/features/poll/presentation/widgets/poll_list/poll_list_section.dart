import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/poll/data/models/poll_response.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_bloc.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_event.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_state.dart';
import 'package:event_management/features/poll/presentation/widgets/poll_list/poll_stats_dialog.dart';
import 'package:event_management/features/poll/presentation/widgets/poll_list/update_poll_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PollListSection extends StatelessWidget {
  const PollListSection({required this.eventId, super.key});

  final int eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PollListBloc>()..add(PollListFetched(eventId)),
      child: BlocConsumer<PollListBloc, PollListState>(
        listener: (context, state) {
          if (state is PollListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is PollCloseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.green500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coolGray900.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.amber100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.poll_rounded,
                            color: AppColors.amber600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spaceMD),
                        Text('Danh sách Polls', style: AppTextStyles.heading3),
                      ],
                    ),
                    if (state is PollListLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                if (state is PollListLoading && state is! PollListSuccess)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.spaceLG),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is PollListSuccess)
                  _buildPollList(context, state.polls)
                else if (state is PollListError)
                  _buildErrorState(context, state.message)
                else
                  _buildEmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollList(BuildContext context, List<PollResponse> polls) {
    if (polls.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: polls.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final poll = polls[index];
        return _PollListItem(
          poll: poll,
          onViewStats: () => _showStatsDialog(context, poll.id),
          onUpdate: () => _showUpdatePollBottomSheet(context, poll),
          onClose: () => _showCloseConfirmation(context, poll),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.poll_outlined,
              size: 48,
              color: AppColors.coolGray500,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            Text('Chưa có poll nào', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              'Nhấn "Tạo Poll mới" để bắt đầu',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.red500),
            const SizedBox(height: AppSpacing.spaceMD),
            Text(
              'Không thể tải danh sách polls',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            ElevatedButton(
              onPressed: () {
                context.read<PollListBloc>().add(PollListFetched(eventId));
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, int pollId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          PollStatsDialog(pollId: pollId, eventId: eventId),
    );
  }

  void _showUpdatePollBottomSheet(BuildContext context, PollResponse poll) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => UpdatePollBottomSheet(
        poll: poll,
        eventId: eventId,
        onPollUpdated: () {
          context.read<PollListBloc>().add(PollListRefreshed(eventId));
        },
      ),
    );
  }

  void _showCloseConfirmation(BuildContext context, PollResponse poll) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận đóng poll'),
        content: Text('Bạn có chắc chắn muốn đóng poll "${poll.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PollListBloc>().add(PollClosed(poll.id, eventId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            child: const Text('Đóng poll'),
          ),
        ],
      ),
    );
  }
}

class _PollListItem extends StatelessWidget {
  const _PollListItem({
    required this.poll,
    required this.onViewStats,
    required this.onUpdate,
    required this.onClose,
  });

  final PollResponse poll;
  final VoidCallback onViewStats;
  final VoidCallback onUpdate;
  final VoidCallback onClose;

  String _getStatusText() {
    if (poll.isDelete) return 'Đã đóng';
    final now = DateTime.now();
    if (now.isBefore(poll.startTime)) return 'Sắp bắt đầu';
    if (now.isAfter(poll.endTime)) return 'Đã kết thúc';
    return 'Đang diễn ra';
  }

  Color _getStatusColor() {
    if (poll.isDelete) return AppColors.coolGray500;
    final now = DateTime.now();
    if (now.isBefore(poll.startTime)) return AppColors.blue400;
    if (now.isAfter(poll.endTime)) return AppColors.red500;
    return AppColors.green500;
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMD,
        vertical: AppSpacing.spaceXS,
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.amber100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.poll_rounded,
          color: AppColors.amber600,
          size: 24,
        ),
      ),
      title: Text(poll.title, style: AppTextStyles.heading5),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: statusColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  statusText,
                  style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Flexible(
                child: Text(
                  poll.pollType.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.coolGray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('dd/MM/yyyy HH:mm', 'vi').format(poll.startTime)} - ${DateFormat('dd/MM/yyyy HH:mm', 'vi').format(poll.endTime)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.coolGray500,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'stats':
              onViewStats();
            case 'update':
              onUpdate();
            case 'close':
              if (!poll.isDelete) {
                onClose();
              }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'stats',
            child: Row(
              children: [
                Icon(Icons.bar_chart_rounded, size: 20),
                SizedBox(width: 8),
                Text('Xem thống kê'),
              ],
            ),
          ),
          if (!poll.isDelete)
            const PopupMenuItem(
              value: 'update',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
          if (!poll.isDelete)
            const PopupMenuItem(
              value: 'close',
              child: Row(
                children: [
                  Icon(Icons.close_rounded, size: 20, color: AppColors.red500),
                  SizedBox(width: 8),
                  Text('Đóng poll', style: TextStyle(color: AppColors.red500)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
