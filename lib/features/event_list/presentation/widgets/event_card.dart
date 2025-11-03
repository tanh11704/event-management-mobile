import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event_list/data/models/event.dart';
import 'package:event_management/features/event_list/data/models/event_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  const EventCard({required this.event, super.key, this.onTap, this.index = 0});

  final Event event;
  final VoidCallback? onTap;
  final int index;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Staggered animation delay
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _animationController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
            ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) {
              _animationController.reverse();
            },
            onTapUp: (_) {
              _animationController.forward();
              widget.onTap?.call();
            },
            onTapCancel: () {
              _animationController.forward();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                child: ColoredBox(
                  color: AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Banner Image với gradient overlay
                      Stack(
                        children: [
                          _buildBanner(),
                          // Gradient overlay cho text readability
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.white.withOpacity(0.95),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Status badge positioned on banner
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _buildStatusBadge(),
                          ),
                        ],
                      ),

                      // Content Section
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spaceMD,
                            vertical: AppSpacing.spaceXM + 2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title with better styling
                              Text(
                                widget.event.title,
                                style: AppTextStyles.heading4.copyWith(
                                  color: AppColors.coolGray900,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.spaceXS),

                              // Divider
                              Container(
                                height: 1,
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.spaceXS,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.coolGray50,
                                      AppColors.border,
                                      AppColors.coolGray50,
                                    ],
                                  ),
                                ),
                              ),

                              // Event Details - using Flexible instead of Spacer
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildInfoRow(
                                      icon: Icons.access_time_rounded,
                                      text: _formatDateTime(
                                        widget.event.startTime,
                                      ),
                                      iconColor: AppColors.vkuBlue,
                                    ),
                                    if (widget.event.location != null) ...[
                                      const SizedBox(height: 5),
                                      _buildInfoRow(
                                        icon: Icons.location_on_rounded,
                                        text: widget.event.location!,
                                        iconColor: AppColors.green500,
                                      ),
                                    ],
                                    if (widget.event.maxParticipants !=
                                        null) ...[
                                      const SizedBox(height: 5),
                                      _buildParticipantsRow(),
                                    ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: widget.event.banner != null && widget.event.banner!.isNotEmpty
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.event.banner!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholder();
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.coolGray900.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Icon(
          Icons.calendar_today_rounded,
          size: 48,
          color: AppColors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 13, color: iconColor),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w500,
              height: 1.3,
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsRow() {
    final current = widget.event.currentParticipants ?? 0;
    final max = widget.event.maxParticipants ?? 0;
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.amber400.withOpacity(0.15),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.people_rounded,
            size: 13,
            color: AppColors.amber600,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current/$max',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.coolGray700,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 3,
                  backgroundColor: AppColors.coolGray50,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 0.8
                        ? AppColors.red500
                        : percentage > 0.5
                        ? AppColors.amber400
                        : AppColors.green500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;
    LinearGradient? gradient;

    switch (widget.event.status) {
      case EventStatus.upcoming:
        backgroundColor = AppColors.vkuBlue;
        textColor = AppColors.white;
        label = 'Sắp diễn ra';
        icon = Icons.schedule_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.vkuBlue, AppColors.blue400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EventStatus.ongoing:
        backgroundColor = AppColors.green500;
        textColor = AppColors.white;
        label = 'Đang diễn ra';
        icon = Icons.play_circle_filled_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.green500, AppColors.green800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EventStatus.completed:
        backgroundColor = AppColors.coolGray900;
        textColor = AppColors.white;
        label = 'Đã kết thúc';
        icon = Icons.check_circle_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.coolGray900, AppColors.coolGray700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EventStatus.cancelled:
        backgroundColor = AppColors.red500;
        textColor = AppColors.white;
        label = 'Đã hủy';
        icon = Icons.cancel_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.red500, AppColors.red800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: backgroundColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: textColor),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              fontSize: 10.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(dateTime);
  }
}
