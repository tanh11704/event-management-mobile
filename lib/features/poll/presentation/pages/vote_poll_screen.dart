import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:event_management/features/poll/presentation/bloc/vote_poll/vote_poll_bloc.dart';
import 'package:event_management/features/poll/presentation/bloc/vote_poll/vote_poll_event.dart';
import 'package:event_management/features/poll/presentation/bloc/vote_poll/vote_poll_state.dart';
import 'package:event_management/features/poll/presentation/widgets/vote_poll/poll_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Screen để người dùng bỏ phiếu trong poll
class VotePollScreen extends StatelessWidget {
  const VotePollScreen({required this.pollId, super.key});

  final int pollId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<VotePollBloc>()..add(VotePollFetched(pollId)),
      child: _VotePollView(pollId: pollId),
    );
  }
}

class _VotePollView extends StatefulWidget {
  const _VotePollView({required this.pollId});

  final int pollId;

  @override
  State<_VotePollView> createState() => _VotePollViewState();
}

class _VotePollViewState extends State<_VotePollView> {
  Set<int> _selectedOptionIds = <int>{};
  bool? _isUserRegistered;
  bool _isCheckingPermission = false;
  bool _hasVoted = false;
  Set<int> _myVotedOptionIds = <int>{};
  PollResponse? _currentPoll;

  Future<void> _checkUserPermission(int eventId) async {
    if (_isCheckingPermission) return;

    setState(() {
      _isCheckingPermission = true;
    });

    try {
      final eventRepository = di.sl<EventRepository>();
      final eventDetail = await eventRepository.getEventDetail(eventId);
      if (mounted) {
        setState(() {
          _isUserRegistered = eventDetail.isUserRegistered ?? false;
          _isCheckingPermission = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUserRegistered = false;
          _isCheckingPermission = false;
        });
      }
    }
  }

  void _toggleOption(int optionId, PollType pollType) {
    setState(() {
      if (pollType == PollType.singleChoice) {
        _selectedOptionIds.clear();
        _selectedOptionIds.add(optionId);
      } else {
        if (_selectedOptionIds.contains(optionId)) {
          _selectedOptionIds.remove(optionId);
        } else {
          _selectedOptionIds.add(optionId);
        }
      }
    });
  }

  void _handleSubmit(BuildContext context, int pollId) {
    if (_selectedOptionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một lựa chọn'),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isUserRegistered == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần tham gia sự kiện trước khi bỏ phiếu'),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _hasVoted = true; // Set flag before submitting
    context.read<VotePollBloc>().add(
      VotePollSubmitted(pollId: pollId, optionIds: _selectedOptionIds.toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VotePollBloc, VotePollState>(
        listener: (context, state) {
          if (state is VotePollError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is VotePollSuccess) {
            // Save current poll to widget state
            _currentPoll = state.poll;

            // Fetch my voted options when poll is loaded
            if (state.poll.hasVoted && _myVotedOptionIds.isEmpty) {
              context.read<VotePollBloc>().add(
                MyVotedOptionsFetched(state.poll.id),
              );
            }

            if (_hasVoted) {
              // Vote was successful
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bỏ phiếu thành công!'),
                  backgroundColor: AppColors.green500,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Pop back after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              });
              _hasVoted = false; // Reset flag
            }
          } else if (state is MyVotedOptionsSuccess) {
            // Update selected options with my voted options
            setState(() {
              _myVotedOptionIds = state.myVotedOptions.optionIds.toSet();
              _selectedOptionIds = _myVotedOptionIds.toSet();
            });
          }
        },
        builder: (context, state) {
          if (state is VotePollLoading && state is! VotePollSuccess) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is VotePollError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Bỏ phiếu'),
                backgroundColor: AppColors.vkuBlue,
                foregroundColor: AppColors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.red500,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text('Không thể tải poll', style: AppTextStyles.heading4),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Text(
                      state.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.coolGray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spaceLG),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VotePollBloc>().add(
                          VotePollFetched(widget.pollId),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Handle MyVotedOptionsSuccess - use saved poll if available
          if (state is MyVotedOptionsSuccess && _currentPoll != null) {
            final poll = _currentPoll!;
            const isLoading = false;
            return _buildPollContent(
              context: context,
              poll: poll,
              isLoading: isLoading,
            );
          }

          if (state is VotePollSuccess) {
            final poll = state.poll;
            const isLoading = false;

            // If user has already voted, no need to check permission
            // Just show the poll content with voted options
            if (poll.hasVoted) {
              // Fetch my voted options if not already fetched
              if (_myVotedOptionIds.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<VotePollBloc>().add(
                    MyVotedOptionsFetched(poll.id),
                  );
                });
              }
              return _buildPollContent(
                context: context,
                poll: poll,
                isLoading: isLoading,
              );
            }

            // Check permission on first load (after build phase) only if not voted
            if (_isUserRegistered == null && !_isCheckingPermission) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkUserPermission(poll.eventId);
              });
            }

            // Show loading while checking permission
            if (_isCheckingPermission || _isUserRegistered == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return _buildPollContent(
              context: context,
              poll: poll,
              isLoading: isLoading,
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildPollContent({
    required BuildContext context,
    required PollResponse poll,
    required bool isLoading,
  }) {
    final now = DateTime.now();
    final isPollActive =
        !poll.isDelete &&
        now.isAfter(poll.startTime) &&
        now.isBefore(poll.endTime);
    final canVote =
        isPollActive && !poll.hasVoted && (_isUserRegistered ?? false);

    return CustomScrollView(
      slivers: [
        // App Bar với gradient
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.vkuBlue,
          foregroundColor: AppColors.white,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final isCollapsed = constraints.maxHeight <= 120;
              return FlexibleSpaceBar(
                title: isCollapsed
                    ? Text(
                        poll.title,
                        style: AppTextStyles.heading5.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.spaceLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.poll_rounded,
                              color: AppColors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          Text(
                            'Bỏ phiếu',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceXS),
                          Text(
                            poll.title,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poll Info Card
                _PollInfoCard(poll: poll),
                const SizedBox(height: AppSpacing.spaceLG),

                // Status Badge
                _PollStatusBadge(
                  isActive: isPollActive,
                  hasVoted: poll.hasVoted,
                ),
                const SizedBox(height: AppSpacing.spaceLG),

                // Options
                if (canVote) ...[
                  Text(
                    poll.pollType == PollType.singleChoice
                        ? 'Chọn một lựa chọn'
                        : 'Chọn một hoặc nhiều lựa chọn',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.coolGray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMD),
                  ...poll.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedOptionIds.contains(option.id);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < poll.options.length - 1
                            ? AppSpacing.spaceMD
                            : 0,
                      ),
                      child: PollOptionCard(
                        option: option,
                        isSelected: isSelected,
                        pollType: poll.pollType,
                        onTap: () => _toggleOption(option.id, poll.pollType),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.spaceXL),
                ] else if (poll.hasVoted) ...[
                  // Show voted options
                  Text(
                    'Lựa chọn của bạn',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.coolGray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMD),
                  ...poll.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isMyVote = _myVotedOptionIds.contains(option.id);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < poll.options.length - 1
                            ? AppSpacing.spaceMD
                            : 0,
                      ),
                      child: PollOptionCard(
                        option: option,
                        isSelected: isMyVote,
                        pollType: poll.pollType,
                        onTap: () {}, // Disabled when already voted
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.spaceLG),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceLG),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.green500.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green500,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bạn đã bỏ phiếu',
                                style: AppTextStyles.heading5.copyWith(
                                  color: AppColors.green800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cảm ơn bạn đã tham gia bỏ phiếu!',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.green800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!(_isUserRegistered ?? false) && isPollActive) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceLG),
                    decoration: BoxDecoration(
                      color: AppColors.amber100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.amber400.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.amber600,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cần tham gia sự kiện',
                                style: AppTextStyles.heading5.copyWith(
                                  color: AppColors.amber800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bạn cần tham gia sự kiện trước khi có thể bỏ phiếu',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.amber800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceLG),
                    decoration: BoxDecoration(
                      color: AppColors.coolGray50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.coolGray500,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.spaceMD),
                        Expanded(
                          child: Text(
                            isPollActive
                                ? 'Poll này đã kết thúc'
                                : 'Poll này chưa bắt đầu hoặc đã kết thúc',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.coolGray700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Submit Button
                if (canVote) ...[
                  const SizedBox(height: AppSpacing.spaceLG),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handleSubmit(context, poll.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vkuBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spaceMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.how_to_vote_rounded, size: 20),
                                const SizedBox(width: AppSpacing.spaceXM),
                                Text(
                                  'Xác nhận bỏ phiếu',
                                  style: AppTextStyles.heading5.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.spaceXL),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget hiển thị thông tin poll
class _PollInfoCard extends StatelessWidget {
  const _PollInfoCard({required this.poll});

  final PollResponse poll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
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
                      poll.pollType.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.amber600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${poll.options.length} lựa chọn',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coolGray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Bắt đầu',
            value: DateFormat('dd/MM/yyyy HH:mm', 'vi').format(poll.startTime),
          ),
          const SizedBox(height: AppSpacing.spaceXM),
          _InfoRow(
            icon: Icons.event_available_rounded,
            label: 'Kết thúc',
            value: DateFormat('dd/MM/yyyy HH:mm', 'vi').format(poll.endTime),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.coolGray500),
        const SizedBox(width: AppSpacing.spaceXM),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray500),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.coolGray900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget hiển thị status badge
class _PollStatusBadge extends StatelessWidget {
  const _PollStatusBadge({required this.isActive, required this.hasVoted});

  final bool isActive;
  final bool hasVoted;

  @override
  Widget build(BuildContext context) {
    if (hasVoted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceXM,
        ),
        decoration: BoxDecoration(
          color: AppColors.green50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.green500, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.green500,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Đã bỏ phiếu',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.green800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceXM,
        ),
        decoration: BoxDecoration(
          color: AppColors.blue50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.blue400, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.radio_button_checked_rounded,
              color: AppColors.blue400,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Đang diễn ra',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.vkuBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMD,
        vertical: AppSpacing.spaceXM,
      ),
      decoration: BoxDecoration(
        color: AppColors.coolGray50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.coolGray500, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cancel_rounded,
            color: AppColors.coolGray500,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Đã kết thúc',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
