import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_app_bar.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_empty_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_error_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_filter_chips.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_grid.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_loading_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_list_search_bar.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  EventStatus? _selectedStatus;
  final ScrollController _scrollController = ScrollController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onSearchFocusChanged);

    // Load initial data
    context.read<EventListBloc>().add(const EventListFetchAll());
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  void _onSearchSubmitted(String value) {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ẩn bàn phím khi tap ra ngoài TextField
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
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
              EventListAppBar(
                tabController: _tabController,
                authRepository: di.sl(),
              ),
              _buildSearchAndFilterSection(),
              _buildEventListContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return SliverToBoxAdapter(
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
            EventListSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              isFocused: _isSearchFocused,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
            BlocBuilder<EventListBloc, EventListState>(
              builder: (context, state) {
                if (state is EventListLoaded || state is EventListEmpty) {
                  final counters = state is EventListLoaded
                      ? state.counters
                      : (state as EventListEmpty).counters;

                  return EventListFilterChips(
                    counters: counters,
                    selectedStatus: _selectedStatus,
                    onStatusChanged: _onStatusFilterChanged,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventListContent() {
    return BlocBuilder<EventListBloc, EventListState>(
      builder: (context, state) {
        if (state is EventListLoading) {
          return const EventListLoadingState();
        }

        if (state is EventListError) {
          return EventListErrorState(
            error: state.error,
            tabIndex: _tabController.index,
          );
        }

        if (state is EventListEmpty) {
          return const EventListEmptyState();
        }

        if (state is EventListLoaded) {
          return EventListGrid(
            events: state.events,
            hasNextPage: state.hasNextPage,
            onEventTap: (event) {
              // TODO: Navigate to event detail
            },
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
