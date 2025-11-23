import 'dart:async';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/utils/date_time_formatter.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_card_banner.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_info_row.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_participants_row.dart';
import 'package:flutter/material.dart';

class EventCardAdmin extends StatefulWidget {
  const EventCardAdmin({
    required this.event,
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  @override
  State<EventCardAdmin> createState() => _EventCardAdminState();
}

class _EventCardAdminState extends State<EventCardAdmin>
    with TickerProviderStateMixin {
  late AnimationController _loadController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_loadController);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _loadController, curve: Curves.easeOutCubic),
        );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) {
        _loadController.forward();
      }
    });
  }

  @override
  void dispose() {
    _loadController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _tapController.forward();
  }

  void _onTapUp(_) {
    _tapController.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  void _handleEdit(BuildContext context) {
    widget.onEdit?.call();
  }

  void _handleDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.red500,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Xác nhận xóa', style: AppTextStyles.heading3),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa sự kiện "${widget.event.title}"? Hành động này không thể hoàn tác.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.coolGray700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red500,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Stack(
              children: [
                // Main card content
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coolGray900.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.coolGray900.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EventCardBanner(event: widget.event),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.spaceMD,
                              AppSpacing.spaceXM,
                              AppSpacing.spaceMD,
                              AppSpacing.spaceXM,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Event info
                                EventInfoRow(
                                  icon: Icons.access_time_rounded,
                                  text:
                                      DateTimeFormatter.formatDateTimeWithTime(
                                        widget.event.startTime,
                                      ),
                                  iconColor: AppColors.vkuBlue,
                                ),
                                if (widget.event.location != null) ...[
                                  const SizedBox(height: AppSpacing.spaceXS),
                                  EventInfoRow(
                                    icon: Icons.location_on_rounded,
                                    text: widget.event.location!,
                                    iconColor: AppColors.green500,
                                  ),
                                ],
                                if (widget.event.maxParticipants != null) ...[
                                  const SizedBox(height: AppSpacing.spaceXS),
                                  EventParticipantsRow(
                                    currentParticipants:
                                        widget.event.currentParticipants,
                                    maxParticipants:
                                        widget.event.maxParticipants,
                                  ),
                                ],
                                // Admin info section - Only show if space allows
                                if (widget.event.createdByName != null) ...[
                                  const SizedBox(height: AppSpacing.spaceXS),
                                  EventInfoRow(
                                    icon: Icons.person_rounded,
                                    text:
                                        widget.event.createdByName!.length > 20
                                        ? 'Tạo bởi: ${widget.event.createdByName!.substring(0, 20)}...'
                                        : 'Tạo bởi: ${widget.event.createdByName}',
                                    iconColor: AppColors.coolGray700,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        // Action buttons section
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spaceMD,
                            vertical: AppSpacing.spaceXM,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coolGray50,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.border.withOpacity(0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // View button
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.visibility_rounded,
                                  label: 'Xem',
                                  color: AppColors.vkuBlue,
                                  onTap: () {
                                    widget.onTap?.call();
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.spaceXS),
                              // Edit button
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.edit_rounded,
                                  label: 'Sửa',
                                  color: AppColors.amber600,
                                  onTap: () => _handleEdit(context),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.spaceXS),
                              // Delete button
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.delete_rounded,
                                  label: 'Xóa',
                                  color: AppColors.red500,
                                  onTap: () => _handleDelete(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceXM,
          vertical: AppSpacing.spaceXS + 2,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
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
}
