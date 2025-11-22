import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/attendees_tab.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_tab.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/overview_tab.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/tools_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({
    required this.eventDetail,
    this.cameFromAdmin = false,
    super.key,
  });

  final EventDetailResponse eventDetail;
  final bool cameFromAdmin;

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (widget.cameFromAdmin) {
              context.go(AppRoutes.admin);
            } else {
              context.go(AppRoutes.eventList);
            }
          },
        ),
        title: Text(
          widget.eventDetail.title,
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.vkuBlue,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          labelStyle: AppTextStyles.heading5.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white.withOpacity(0.7),
          ),
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Người tham dự'),
            Tab(text: 'Công cụ & Cài đặt'),
            Tab(text: 'Chỉnh sửa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(eventDetail: widget.eventDetail),
          AttendeesTab(eventDetail: widget.eventDetail),
          ToolsSettingsTab(eventDetail: widget.eventDetail),
          EditEventTab(eventDetail: widget.eventDetail),
        ],
      ),
    );
  }
}
