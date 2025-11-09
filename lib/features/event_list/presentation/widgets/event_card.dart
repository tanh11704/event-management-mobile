import 'dart:async'; // Cần cho Future.delayed

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

class _EventCardState extends State<EventCard> with TickerProviderStateMixin {
  // _loadController: Dành cho animation fade/slide khi card xuất hiện
  // _tapController: Dành cho animation scale khi người dùng nhấn
  late AnimationController _loadController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Thiết lập hiệu ứng tải hoạt ảnh (làm mờ và trượt)
    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Kéo dài hơn một chút
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_loadController);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _loadController, curve: Curves.easeOutCubic),
        );

    // 2. Thiết lập hoạt ảnh chạm (Tỷ lệ)
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Phản hồi nhanh
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));

    // Độ trễ hoạt ảnh so le
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

  // Logic nhấn (tap) mượt mà hơn
  void _onTapDown(_) {
    _tapController.forward();
  }

  void _onTapUp(_) {
    // Đợi animation trở lại vị trí cũ rồi mới gọi onTap
    _tapController.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    _tapController.reverse(); // Trở lại vị trí cũ
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation, // Dùng animation load
      child: SlideTransition(
        position: _slideAnimation, // Dùng animation load
        child: ScaleTransition(
          scale: _scaleAnimation, // Dùng animation tap
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
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
              // ClipRRect để bo góc banner và content
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBannerAndTitle(),
                    // Mục Nội dung
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.spaceMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow(
                            icon: Icons.access_time_rounded,
                            text: _formatDateTime(widget.event.startTime),
                            iconColor: AppColors.vkuBlue,
                          ),

                          if (widget.event.location != null) ...[
                            const SizedBox(height: AppSpacing.spaceXM),
                            _buildInfoRow(
                              icon: Icons.location_on_rounded,
                              text: widget.event.location!,
                              iconColor: AppColors.green500,
                            ),
                          ],

                          if (widget.event.maxParticipants != null) ...[
                            const SizedBox(height: AppSpacing.spaceXM),
                            _buildParticipantsRow(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// gộp Banner, Scrim, Title, và Badge
  Widget _buildBannerAndTitle() {
    return Stack(
      children: [
        // 1. Banner Image
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: widget.event.banner != null && widget.event.banner!.isNotEmpty
              ? Image.network(
                  widget.event.banner!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder(),
        ),

        // 2. Scrim (lớp phủ tối) để làm nổi bật chữ
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.coolGray900.withOpacity(0),
                  AppColors.coolGray900.withOpacity(0.1),
                  AppColors.coolGray900.withOpacity(0.7),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),

        // 3. Status Badge
        Positioned(
          top: AppSpacing.spaceMD,
          right: AppSpacing.spaceMD,
          child: _buildStatusBadge(),
        ),

        // 4. Title
        Positioned(
          bottom: AppSpacing.spaceMD,
          left: AppSpacing.spaceMD,
          right: AppSpacing.spaceMD,
          child: Text(
            widget.event.title,
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.white, // Chữ trắng
              fontWeight: FontWeight.w700,
              height: 1.25,
              fontSize: 16, // Tăng font size
              // Thêm shadow cho chữ
              shadows: [
                BoxShadow(
                  color: AppColors.coolGray900.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
          padding: const EdgeInsets.all(4), // Tăng nhẹ
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 14, color: iconColor), // Tăng nhẹ
        ),
        const SizedBox(width: AppSpacing.spaceXM), // Dùng hằng số
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w500,
              height: 1.4, // Tăng chiều cao
              fontSize: 12.5, // Tăng font
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
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.amber400.withOpacity(0.15),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.people_rounded,
            size: 14,
            color: AppColors.amber600,
          ),
        ),
        const SizedBox(width: AppSpacing.spaceXM),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Số người tham gia: $current / $max', // Thêm context
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.coolGray700,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.spaceXS + 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 5, // Dày hơn
                  backgroundColor: AppColors.coolGray50, // Nền rõ hơn
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

    // Badge này đã rất đẹp, giữ nguyên logic, chỉ điều chỉnh padding
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor), // Icon nhỏ hơn
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700, // Giảm từ w900
              letterSpacing: 0.3,
              fontSize: 11, // Tăng nhẹ
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
