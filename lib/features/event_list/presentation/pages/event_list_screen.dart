import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/core/widgets/user_menu.dart';
import 'package:event_management/features/event_list/data/models/event_status.dart';
import 'package:event_management/features/event_list/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event_list/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event_list/presentation/bloc/event_list_state.dart';
import 'package:event_management/features/event_list/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  EventStatus? _selectedStatus;
  final ScrollController _scrollController = ScrollController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<EventListBloc>().add(const EventListFetchAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      // Update UI when tab changes
    });

    if (_tabController.indexIsChanging) {
      final isManaged = _tabController.index == 1;
      _selectedStatus = null;
      _searchController.clear();

      if (isManaged) {
        context.read<EventListBloc>().add(const EventListFetchManaged());
      } else {
        context.read<EventListBloc>().add(const EventListFetchAll());
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final isManaged = _tabController.index == 1;
      context.read<EventListBloc>().add(
        EventListLoadMore(isManaged: isManaged),
      );
    }
  }

  void _onStatusFilterChanged(EventStatus? status) {
    setState(() {
      _selectedStatus = status;
    });

    final isManaged = _tabController.index == 1;
    context.read<EventListBloc>().add(
      EventListFilterChanged(status: status, isManaged: isManaged),
    );
  }

  void _onSearchChanged(String value) {
    final isManaged = _tabController.index == 1;
    context.read<EventListBloc>().add(
      EventListSearchChanged(
        search: value.isEmpty ? null : value,
        isManaged: isManaged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final isManaged = _tabController.index == 1;
          context.read<EventListBloc>().add(
            EventListRefresh(isManaged: isManaged),
          );
          // Wait for the refresh to complete
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        color: AppColors.vkuBlue,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Enhanced AppBar with gradient
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.vkuBlue,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.spaceMD),
                  child: UserMenu(authRepository: di.sl()),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.spaceMD,
                        AppSpacing.spaceMD,
                        AppSpacing.spaceMD,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Danh sách sự kiện',
                                  style: AppTextStyles.heading1.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green500,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.green500.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'LIVE',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.vkuBlue,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coolGray900.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coolGray900.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.vkuBlue,
                    unselectedLabelColor: AppColors.white.withOpacity(0.8),
                    labelStyle: AppTextStyles.heading5.copyWith(
                      color: AppColors.vkuBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: AppTextStyles.heading5.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isSelected = _tabController.index == 0;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_available_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.vkuBlue
                                      : AppColors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: AppSpacing.spaceXM),
                                const Text('Tất cả sự kiện'),
                              ],
                            );
                          },
                        ),
                      ),
                      Tab(
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            final isSelected = _tabController.index == 1;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.manage_accounts_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.vkuBlue
                                      : AppColors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: AppSpacing.spaceXM),
                                const Text('Sự kiện quản lý'),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search and Filter Section
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coolGray900.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Enhanced Search Bar
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.spaceMD),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isSearchFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.vkuBlue.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.coolGray900.withOpacity(
                                    0.08,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onTap: () => setState(() => _isSearchFocused = true),
                        onEditingComplete: () =>
                            setState(() => _isSearchFocused = false),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sự kiện...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.coolGray500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _isSearchFocused
                                ? AppColors.vkuBlue
                                : AppColors.coolGray500,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  color: AppColors.coolGray500,
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _isSearchFocused
                                  ? AppColors.vkuBlue
                                  : AppColors.border,
                              width: _isSearchFocused ? 2 : 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _isSearchFocused
                                  ? AppColors.vkuBlue
                                  : AppColors.border,
                              width: _isSearchFocused ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.vkuBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spaceMD,
                            vertical: AppSpacing.spaceMD,
                          ),
                        ),
                      ),
                    ),

                    // Enhanced Status Filter
                    BlocBuilder<EventListBloc, EventListState>(
                      builder: (context, state) {
                        if (state is EventListLoaded ||
                            state is EventListEmpty) {
                          final counters = state is EventListLoaded
                              ? state.counters
                              : (state as EventListEmpty).counters;

                          return Container(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.spaceMD,
                              0,
                              AppSpacing.spaceMD,
                              AppSpacing.spaceMD,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip(
                                    label: 'Tất cả',
                                    count:
                                        counters.upcoming +
                                        counters.ongoing +
                                        counters.completed +
                                        counters.cancelled,
                                    isSelected: _selectedStatus == null,
                                    onTap: () => _onStatusFilterChanged(null),
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  const SizedBox(width: AppSpacing.spaceXM),
                                  _buildFilterChip(
                                    label: 'Sắp diễn ra',
                                    count: counters.upcoming,
                                    isSelected:
                                        _selectedStatus == EventStatus.upcoming,
                                    onTap: () => _onStatusFilterChanged(
                                      EventStatus.upcoming,
                                    ),
                                    color: AppColors.vkuBlue,
                                  ),
                                  const SizedBox(width: AppSpacing.spaceXM),
                                  _buildFilterChip(
                                    label: 'Đang diễn ra',
                                    count: counters.ongoing,
                                    isSelected:
                                        _selectedStatus == EventStatus.ongoing,
                                    onTap: () => _onStatusFilterChanged(
                                      EventStatus.ongoing,
                                    ),
                                    color: AppColors.green500,
                                  ),
                                  const SizedBox(width: AppSpacing.spaceXM),
                                  _buildFilterChip(
                                    label: 'Đã kết thúc',
                                    count: counters.completed,
                                    isSelected:
                                        _selectedStatus ==
                                        EventStatus.completed,
                                    onTap: () => _onStatusFilterChanged(
                                      EventStatus.completed,
                                    ),
                                    color: AppColors.coolGray700,
                                  ),
                                  const SizedBox(width: AppSpacing.spaceXM),
                                  _buildFilterChip(
                                    label: 'Đã hủy',
                                    count: counters.cancelled,
                                    isSelected:
                                        _selectedStatus ==
                                        EventStatus.cancelled,
                                    onTap: () => _onStatusFilterChanged(
                                      EventStatus.cancelled,
                                    ),
                                    color: AppColors.red500,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Event List
            BlocBuilder<EventListBloc, EventListState>(
              builder: (context, state) {
                if (state is EventListLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.vkuBlue,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          Text(
                            'Đang tải sự kiện...',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is EventListError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.spaceLG),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.spaceLG),
                              decoration: const BoxDecoration(
                                color: AppColors.red100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: AppColors.red500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spaceLG),
                            Text(
                              'Đã xảy ra lỗi',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: AppSpacing.spaceXS),
                            Text(
                              state.error,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.spaceLG),
                            ElevatedButton.icon(
                              onPressed: () {
                                final isManaged = _tabController.index == 1;
                                context.read<EventListBloc>().add(
                                  EventListRefresh(isManaged: isManaged),
                                );
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vkuBlue,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.spaceLG,
                                  vertical: AppSpacing.spaceMD,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is EventListEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.spaceLG),
                            decoration: const BoxDecoration(
                              color: AppColors.coolGray50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_busy_rounded,
                              size: 64,
                              color: AppColors.coolGray500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceLG),
                          Text(
                            'Không có sự kiện nào',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.spaceXS),
                          Text(
                            'Hãy thử thay đổi bộ lọc',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is EventListLoaded) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.spaceMD),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.spaceMD,
                            mainAxisSpacing: AppSpacing.spaceMD,
                            childAspectRatio: 0.64,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.events.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final event = state.events[index];
                          return EventCard(
                            event: event,
                            index: index,
                            onTap: () {
                              // TODO: Navigate to event detail
                            },
                          );
                        },
                        childCount:
                            state.events.length + (state.hasNextPage ? 1 : 0),
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    LinearGradient? gradient,
    Color? color,
  }) {
    final backgroundColor = color ?? AppColors.coolGray50;

    LinearGradient? chipGradient;
    if (isSelected && gradient != null) {
      chipGradient = gradient;
    } else if (isSelected && color != null) {
      // Create gradient for selected state
      Color? lightColor;
      switch (color) {
        case AppColors.vkuBlue:
          lightColor = AppColors.blue400;
        case AppColors.green500:
          lightColor = AppColors.green800;
        case AppColors.coolGray700:
          lightColor = AppColors.coolGray500;
        case AppColors.red500:
          lightColor = AppColors.red800;
        default:
          lightColor = color;
      }
      chipGradient = LinearGradient(
        colors: [color, lightColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD + 2,
            vertical: AppSpacing.spaceMD,
          ),
          decoration: BoxDecoration(
            gradient: chipGradient,
            color: chipGradient == null && !isSelected ? backgroundColor : null,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
              width: isSelected ? 0 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (color ?? AppColors.vkuBlue).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: (color ?? AppColors.vkuBlue).withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.coolGray900.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label.isNotEmpty) ...[
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.coolGray700,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.3)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.coolGray900.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  count.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.white : AppColors.coolGray700,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
