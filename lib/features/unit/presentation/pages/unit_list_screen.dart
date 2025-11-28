import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_list/unit_list_bloc.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_list/unit_list_event.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_list/unit_list_state.dart';
import 'package:event_management/features/unit/presentation/widgets/unit_tree_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UnitListScreen extends StatefulWidget {
  const UnitListScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<UnitListBloc>().add(const UnitListFetched());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UnitListBloc>().add(const UnitListLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<UnitListBloc>().add(const UnitListSearched(''));
    } else {
      context.read<UnitListBloc>().add(UnitListSearched(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<UnitListBloc, UnitListState>(
      listener: (context, state) {
        if (state is UnitListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar (only if showAppBar is true)
            if (widget.showAppBar)
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppColors.vkuBlue,
                foregroundColor: AppColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Quản Lý Đơn Vị'),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () async {
                      final result = await context.pushNamed<bool>(
                        AppRoutes.unitForm,
                      );
                      // Refresh list if unit was created/updated
                      if (result ?? false && mounted) {
                        context.read<UnitListBloc>().add(
                          const UnitListFetched(),
                        );
                      }
                    },
                    tooltip: 'Thêm đơn vị mới',
                  ),
                ],
              ),

            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.spaceMD),
                color: AppColors.white,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm đơn vị...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.vkuBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.coolGray50,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        _onSearchChanged(value);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ),

            // Content
            if (state is UnitListLoading && state is! UnitListSuccess)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is UnitListError)
              SliverFillRemaining(
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
                      Text(
                        'Không thể tải danh sách đơn vị',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: AppSpacing.spaceXS),
                      Text(
                        state.message,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.spaceLG),
                      ElevatedButton(
                        onPressed: () {
                          context.read<UnitListBloc>().add(
                            const UnitListFetched(),
                          );
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state is UnitListSuccess)
              state.units.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              size: 64,
                              color: AppColors.coolGray500,
                            ),
                            const SizedBox(height: AppSpacing.spaceMD),
                            Text(
                              'Chưa có đơn vị nào',
                              style: AppTextStyles.heading4,
                            ),
                            const SizedBox(height: AppSpacing.spaceXS),
                            Text(
                              'Nhấn nút + để thêm đơn vị mới',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.spaceMD),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Build tree structure
                            final treeItems = _buildTreeStructure(state.units);

                            if (index >= treeItems.length) {
                              if (state.pageResponse.hasNext) {
                                return const Padding(
                                  padding: EdgeInsets.all(AppSpacing.spaceMD),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final treeItem = treeItems[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < treeItems.length - 1
                                    ? AppSpacing.spaceMD
                                    : 0,
                              ),
                              child: UnitTreeItem(
                                unit: treeItem.unit,
                                subUnits: treeItem.subUnits,
                                allUnits: state.units,
                                onTap: (unit) async {
                                  final result = await context.pushNamed<bool>(
                                    AppRoutes.unitFormEdit,
                                    pathParameters: {'id': unit.id.toString()},
                                  );
                                  // Refresh list if unit was created/updated
                                  if (result ?? false && mounted) {
                                    context.read<UnitListBloc>().add(
                                      const UnitListFetched(),
                                    );
                                  }
                                },
                                onDelete: (unit) {
                                  _showDeleteDialog(context, unit);
                                },
                              ),
                            );
                          },
                          childCount:
                              _buildTreeStructure(state.units).length +
                              (state.pageResponse.hasNext ? 1 : 0),
                        ),
                      ),
                    )
            else
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.coolGray50,
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.pushNamed<bool>(AppRoutes.unitForm);
            if (result ?? false && mounted) {
              context.read<UnitListBloc>().add(const UnitListFetched());
            }
          },
          backgroundColor: AppColors.vkuBlue,
          child: const Icon(Icons.add_rounded, color: AppColors.white),
        ),
      );
    }

    return Stack(
      children: [
        ColoredBox(color: AppColors.coolGray50, child: content),
        // Floating Action Button when showAppBar is false
        if (!widget.showAppBar)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await context.pushNamed<bool>(
                  AppRoutes.unitForm,
                );
                if (result ?? false && mounted) {
                  context.read<UnitListBloc>().add(const UnitListFetched());
                }
              },
              backgroundColor: AppColors.vkuBlue,
              child: const Icon(Icons.add_rounded, color: AppColors.white),
            ),
          ),
      ],
    );
  }

  List<_UnitTreeItem> _buildTreeStructure(List<UnitEntity> units) {
    // Separate parent units and sub units
    // A unit is a parent if parentId is null OR parentId equals its own id (self-reference)
    final parentUnits = units
        .where((u) => u.parentId == null || u.parentId == u.id)
        .toList();
    final subUnitsMap = <int, List<UnitEntity>>{};

    for (final unit in units) {
      // Only add to subUnitsMap if parentId exists, is not null, and is different from unit's id
      if (unit.parentId != null && unit.parentId != unit.id) {
        subUnitsMap.putIfAbsent(unit.parentId!, () => []).add(unit);
      }
    }

    // Build tree items
    final treeItems = <_UnitTreeItem>[];
    for (final parent in parentUnits) {
      final subUnits = subUnitsMap[parent.id] ?? [];
      treeItems.add(_UnitTreeItem(unit: parent, subUnits: subUnits));
    }

    return treeItems;
  }

  void _showDeleteDialog(BuildContext context, UnitEntity unit) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa đơn vị "${unit.unitName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Use the original context that has access to UnitListBloc
              context.read<UnitListBloc>().add(UnitListDeleted(unit.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

/// Helper class for tree structure
class _UnitTreeItem {
  const _UnitTreeItem({required this.unit, required this.subUnits});

  final UnitEntity unit;
  final List<UnitEntity> subUnits;
}
