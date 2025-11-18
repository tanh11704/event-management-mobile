import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_counters.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_grid.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<EventListBloc>().add(const EventListFetchAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.account_circle_rounded,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
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
    return BlocBuilder<EventListBloc, EventListState>(
      builder: (context, state) {
        EventCounters? counters;
        final events = state is EventListLoaded
            ? state.events
            : const <Event>[];
        if (state is EventListLoaded) counters = state.counters;
        if (state is EventListEmpty) counters = state.counters;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardCounters(counters: counters),
                    const SizedBox(height: 24),
                    _buildSearchAndFilter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (state is EventListLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else
              EventListGrid(
                events: events,
                hasNextPage: state is EventListLoaded
                    ? state.hasNextPage
                    : false,
                onEventTap: (event) {
                  context.go('/events/${event.id}');
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Row 1: Search bar và Filter
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.coolGray500.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sự kiện...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.coolGray500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.coolGray500.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.coolGray500.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.coolGray700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: Thêm mới và Refresh
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
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                context.read<EventListBloc>().add(const EventListFetchAll());
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_rounded,
            size: 80,
            color: AppColors.coolGray500.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Quản lý người dùng',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chức năng đang được phát triển',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.coolGray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitManagementTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_rounded,
            size: 80,
            color: AppColors.coolGray500.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Quản lý đơn vị',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chức năng đang được phát triển',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.coolGray500,
            ),
          ),
        ],
      ),
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
        final aspectRatio = isWide ? 2.2 : 2.5;
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
