import 'dart:async'; // Cần cho Future.delayed

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/utils/date_time_formatter.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_card_banner.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_card_join_button.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_info_row.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_participants_row.dart';
import 'package:flutter/material.dart';

class EventCard extends StatefulWidget {
  const EventCard({required this.event, super.key, this.onTap, this.index = 0});

  final Event event;
  final VoidCallback? onTap;
  final int index;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with TickerProviderStateMixin {
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
            //
            // -----------------------------------------------------------------
            // SỬA LỖI: Bọc toàn bộ card trong một Stack
            // -----------------------------------------------------------------
            child: Stack(
              children: [
                // PHẦN 1: NỀN CARD VÀ NỘI DUNG (KHÔNG BAO GỒM NÚT BẤM)
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

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.spaceMD,
                            AppSpacing.spaceXM,
                            AppSpacing.spaceMD,
                            AppSpacing.spaceLG + AppSpacing.spaceMD,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              EventInfoRow(
                                icon: Icons.access_time_rounded,
                                text: DateTimeFormatter.formatDateTimeWithTime(
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
                                  maxParticipants: widget.event.maxParticipants,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: AppSpacing.spaceMD, // 16px
                  right: AppSpacing.spaceMD, // 16px
                  child: EventCardJoinButton(event: widget.event),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
