import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/event_management/event_management_bloc.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/attendees_tab.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_tab.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/overview_tab.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/tools_settings_tab.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkRole() async {
    try {
      final authRepository = sl<AuthRepository>();
      final currentUser = await authRepository.getAuthUser();
      final currentUserId = currentUser.id;

      // Manager list đến từ backend với quyền MANAGE
      final isManager = widget.eventDetail.manager.any(
        (manager) => manager.userId == currentUserId,
      );

      if (!mounted) return;

      setState(() {
        _isManager = isManager;
        // Nếu chỉ là secretary (STAFF) thì _isManager sẽ là false
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isManager = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EventManagementBloc>(),
      child: Scaffold(
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
            ToolsSettingsTab(
              eventDetail: widget.eventDetail,
              canManageSecretaries: _isManager,
            ),
            EditEventTab(eventDetail: widget.eventDetail, canEdit: _isManager),
          ],
        ),
      ),
    );
  }
}
