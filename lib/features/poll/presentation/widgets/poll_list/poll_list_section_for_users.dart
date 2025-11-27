import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_bloc.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_event.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Section hiển thị danh sách polls cho người dùng thường (không phải manager)
class PollListSectionForUsers extends StatelessWidget {
  const PollListSectionForUsers({
    required this.eventId,
    required this.isUserRegistered,
    super.key,
  });

  final int eventId;
  final bool isUserRegistered;

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
          }
        },
        builder: (context, state) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMD),
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
                        Text('Bình chọn', style: AppTextStyles.heading3),
                      ],
                    ),
                    if (state is PollListLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () {
                          context.read<PollListBloc>().add(
                            PollListRefreshed(eventId),
                          );
                        },
                        tooltip: 'Làm mới',
                        iconSize: 20,
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

    // Filter only active polls for users
    final activePolls = polls.where((poll) {
      final now = DateTime.now();
      return !poll.isDelete &&
          now.isAfter(poll.startTime) &&
          now.isBefore(poll.endTime);
    }).toList();

    if (activePolls.isEmpty) {
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
              Text(
                'Chưa có poll nào đang diễn ra',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PollListBloc>().add(PollListRefreshed(eventId));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: activePolls.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final poll = activePolls[index];
          return _UserPollCard(
            poll: poll,
            isUserRegistered: isUserRegistered,
            onVote: () {
              if (!isUserRegistered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Bạn cần tham gia sự kiện trước khi bỏ phiếu',
                    ),
                    backgroundColor: AppColors.red500,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              context
                  .pushNamed(
                    AppRoutes.votePoll,
                    pathParameters: {'id': poll.id.toString()},
                  )
                  .then((result) {
                    if (result == true) {
                      context.read<PollListBloc>().add(
                        PollListRefreshed(eventId),
                      );
                    }
                  });
            },
          );
        },
      ),
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
}

/// Card hiển thị poll cho người dùng thường
class _UserPollCard extends StatelessWidget {
  const _UserPollCard({
    required this.poll,
    required this.isUserRegistered,
    required this.onVote,
  });

  final PollResponse poll;
  final bool isUserRegistered;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPollActive =
        !poll.isDelete &&
        now.isAfter(poll.startTime) &&
        now.isBefore(poll.endTime);
    final canVote = isPollActive && !poll.hasVoted && isUserRegistered;

    return InkWell(
      onTap: canVote ? onVote : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: canVote
              ? Border.all(
                  color: AppColors.vkuBlue.withValues(alpha: 0.3),
                  width: 2,
                )
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.coolGray900.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poll.title,
                        style: AppTextStyles.heading5.copyWith(
                          color: canVote
                              ? AppColors.vkuBlue
                              : AppColors.coolGray900,
                          fontWeight: canVote
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: canVote
                                ? AppColors.green500
                                : AppColors.coolGray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            poll.pollType.label,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.coolGray500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spaceMD),
                          Text(
                            '${poll.options.length} lựa chọn',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.coolGray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            if (canVote)
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMD,
                    vertical: AppSpacing.spaceMD,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vkuBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.how_to_vote_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.spaceXM),
                      Text(
                        'Bỏ phiếu ngay',
                        style: AppTextStyles.heading5.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!isUserRegistered && isPollActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMD,
                  vertical: AppSpacing.spaceMD,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber400, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.amber600,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spaceXM),
                    Expanded(
                      child: Text(
                        'Tham gia sự kiện để bỏ phiếu',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.amber800,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            else if (poll.hasVoted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMD,
                  vertical: AppSpacing.spaceMD,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green500, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.green500,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spaceXM),
                    Text(
                      'Đã bỏ phiếu',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.green800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
