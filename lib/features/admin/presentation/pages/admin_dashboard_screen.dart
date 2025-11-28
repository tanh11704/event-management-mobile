import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/core/widgets/user_menu.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_bloc.dart';
import 'package:event_management/features/admin/presentation/pages/user_management_screen.dart';
import 'package:event_management/features/admin/presentation/widgets/admin_event_filter_chips.dart';
import 'package:event_management/features/admin/presentation/widgets/admin_event_search_bar.dart';
import 'package:event_management/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:event_management/features/admin/presentation/widgets/event_list_grid_admin.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_state.dart';
import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/shared/data/models/event_counters.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_list/unit_list_bloc.dart';
import 'package:event_management/features/unit/presentation/pages/unit_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  EventStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    context.read<EventListBloc>().add(const EventListFetchAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<EventListBloc>().add(
        const EventListLoadMore(isManaged: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildNavigationTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventManagementTab(),
                _buildUserManagementTab(),
                _buildUnitManagementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.vkuBlue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Admin',
                          style: AppTextStyles.heading5.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản Lý Sự Kiện',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UserMenu(authRepository: di.sl<AuthRepository>()),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Hệ thống quản lý sự kiện chuyên nghiệp',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return ColoredBox(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.vkuBlue,
        indicatorWeight: 3,
        labelColor: AppColors.vkuBlue,
        unselectedLabelColor: AppColors.coolGray500,
        labelStyle: AppTextStyles.heading5.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.heading5.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Quản lý sự kiện'),
          Tab(text: 'Quản lý người dùng'),
          Tab(text: 'Quản lý tên đơn vị'),
        ],
      ),
    );
  }

  Widget _buildEventManagementTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EventListBloc>().add(
          const EventListRefresh(isManaged: false),
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.vkuBlue,
      child: BlocBuilder<EventListBloc, EventListState>(
        builder: (context, state) {
          EventCounters? counters;
          final events = state is EventListLoaded
              ? state.events
              : const <Event>[];
          if (state is EventListLoaded) {
            counters = state.counters;
          }
          if (state is EventListEmpty) {
            counters = state.counters;
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DashboardCounters(counters: counters),
                      const SizedBox(height: AppSpacing.spaceLG),
                      _buildSearchAndFilter(counters),
                      const SizedBox(height: AppSpacing.spaceMD),
                    ],
                  ),
                ),
              ),
              if (state is EventListLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.spaceLG),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (state is EventListError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spaceLG),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: AppColors.red500,
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          Text('Đã xảy ra lỗi', style: AppTextStyles.heading3),
                          const SizedBox(height: AppSpacing.spaceXS),
                          Text(
                            state.error,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.spaceLG),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<EventListBloc>().add(
                                const EventListFetchAll(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (state is EventListEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spaceXL),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.event_busy_rounded,
                            size: 64,
                            color: AppColors.coolGray500,
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          Text(
                            'Chưa có sự kiện nào',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.spaceXS),
                          Text(
                            'Hãy tạo sự kiện đầu tiên của bạn',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                EventListGridAdmin(
                  events: events,
                  hasNextPage: state is EventListLoaded
                      ? state.hasNextPage
                      : false,
                  // Điều hướng sang màn chi tiết sự kiện sẽ được xử lý bên trong EventListGridAdmin
                  // để đảm bảo back từ chi tiết sự kiện quay lại đúng Admin Dashboard với state cũ.
                  onEventEdit: (event) {
                    context.go('/admin/events/${event.id}/edit');
                  },
                  onEventDelete: (event) {
                    // TODO: Implement delete functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Xóa sự kiện "${event.title}" - Chức năng đang được phát triển',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.coolGray500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(EventCounters? counters) {
    if (counters == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Row 1: Search bar
        AdminEventSearchBar(
          controller: _searchController,
          onChanged: (value) {
            context.read<EventListBloc>().add(
              EventListSearchChanged(
                search: value.isEmpty ? null : value,
                isManaged: false,
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        // Row 2: Filter chips
        AdminEventFilterChips(
          counters: counters,
          selectedStatus: _selectedStatus,
          onStatusChanged: (status) {
            setState(() {
              _selectedStatus = status;
            });
            context.read<EventListBloc>().add(
              EventListFilterChanged(status: status, isManaged: false),
            );
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        // Row 3: Thêm mới và Refresh
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => context.go('/create-event'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vkuBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thêm mới',
                        style: AppTextStyles.heading5.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXM),
            InkWell(
              onTap: () {
                context.read<EventListBloc>().add(
                  const EventListRefresh(isManaged: false),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.coolGray500.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.coolGray700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserManagementTab() {
    return BlocProvider(
      create: (context) => di.sl<UserManagementBloc>(),
      child: const UserManagementScreen(),
    );
  }

  Widget _buildUnitManagementTab() {
    return BlocProvider(
      create: (context) => di.sl<UnitListBloc>(),
      child: const UnitListScreen(showAppBar: false),
    );
  }
}

class _DashboardCounters extends StatelessWidget {
  const _DashboardCounters({required this.counters});
  final EventCounters? counters;

  @override
  Widget build(BuildContext context) {
    final total =
        (counters?.upcoming ?? 0) +
        (counters?.ongoing ?? 0) +
        (counters?.completed ?? 0) +
        (counters?.cancelled ?? 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 960;
        final crossAxisCount = isWide ? 5 : 2;
        const spacing = 16.0;
        final aspectRatio = isWide ? 2.0 : 1.8;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
          children: [
            AdminStatCard(
              title: 'Tổng số',
              count: total,
              icon: Icons.leaderboard_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA78BFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            AdminStatCard(
              title: 'Đang diễn ra',
              count: counters?.ongoing ?? 0,
              icon: Icons.play_circle_fill_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            AdminStatCard(
              title: 'Sắp tới',
              count: counters?.upcoming ?? 0,
              icon: Icons.schedule_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            AdminStatCard(
              title: 'Đã kết thúc',
              count: counters?.completed ?? 0,
              icon: Icons.check_circle_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            AdminStatCard(
              title: 'Đã hủy',
              count: counters?.cancelled ?? 0,
              icon: Icons.cancel_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        );
      },
    );
  }
}
