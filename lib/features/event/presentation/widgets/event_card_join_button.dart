import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventCardJoinButton extends StatelessWidget {
  const EventCardJoinButton({required this.event, super.key});

  final Event event;

  bool get _canJoin {
    // Chỉ có thể tham gia nếu:
    // 1. Chưa tham gia (isRegistered == false)
    // 2. Sự kiện đang sắp diễn ra (status == UPCOMING)
    // 3. Có qrJoinToken
    // 4. Chưa đầy (nếu có maxParticipants)
    if (event.isRegistered ?? false) {
      return false; // Đã tham gia rồi
    }
    if (event.status != EventStatus.upcoming) {
      return false; // Sự kiện không còn khả dụng
    }
    if (event.qrJoinToken == null || event.qrJoinToken!.isEmpty) {
      return false; // Không có token
    }
    if (event.maxParticipants != null &&
        event.currentParticipants != null &&
        event.currentParticipants! >= event.maxParticipants!) {
      return false; // Sự kiện đã đầy
    }
    return true;
  }

  String? get _disabledReason {
    if (event.isRegistered ?? false) {
      return 'Bạn đã tham gia sự kiện này';
    }
    if (event.status != EventStatus.upcoming) {
      return 'Sự kiện không còn khả dụng để tham gia';
    }
    if (event.qrJoinToken == null || event.qrJoinToken!.isEmpty) {
      return 'Sự kiện không có mã tham gia';
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
    return BlocListener<EventListBloc, EventListState>(
      listener: (context, state) {
        // Handle errors through exceptions in the join handler
      },
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    if (!_canJoin) {
      return Tooltip(
        message: _disabledReason ?? 'Không thể tham gia',
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD,
            vertical: AppSpacing.spaceXS + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.coolGray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                event.isRegistered ?? false
                    ? Icons.check_circle_rounded
                    : Icons.block_rounded,
                size: 14,
                color: AppColors.coolGray500,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  event.isRegistered ?? false ? 'Đã tham gia' : 'Không thể',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.coolGray700,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _JoinButtonWidget(event: event);
  }
}

class _JoinButtonWidget extends StatefulWidget {
  const _JoinButtonWidget({required this.event});

  final Event event;

  @override
  State<_JoinButtonWidget> createState() => _JoinButtonWidgetState();
}

class _JoinButtonWidgetState extends State<_JoinButtonWidget> {
  bool _isLoading = false;

  Future<void> _handleJoin() async {
    if (widget.event.qrJoinToken == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      context.read<EventListBloc>().add(
        EventListJoinEvent(eventToken: widget.event.qrJoinToken!),
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spaceXM),
                Expanded(
                  child: Text(
                    'Tham gia sự kiện thành công!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.green500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(AppSpacing.spaceMD),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spaceXM),
                Expanded(
                  child: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(AppSpacing.spaceMD),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleJoin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceXS + 2,
        ),
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.primaryGradient,
          color: _isLoading ? AppColors.coolGray500 : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.vkuBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            else
              const Icon(
                Icons.person_add_rounded,
                size: 14,
                color: AppColors.white,
              ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _isLoading ? 'Đang tham gia...' : 'Tham gia',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
