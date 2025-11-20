import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_bloc.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_event.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_state.dart';
import 'package:event_management/features/admin/presentation/widgets/user_management_counters.dart';
import 'package:event_management/features/admin/presentation/widgets/user_management_filters.dart';
import 'package:event_management/features/admin/presentation/widgets/user_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserManagementBloc>().add(const UserManagementFetchAll());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserManagementFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red500,
            ),
          );
        }
      },
      builder: (context, state) {
        return ColoredBox(
          color: const Color(0xFFF8FAFC),
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coolGray900.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.vkuBlue.withOpacity(0.15),
                              AppColors.vkuBlue.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: AppColors.vkuBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quản Lý Người Dùng',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.coolGray900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Theo dõi, tìm kiếm và quản lý tài khoản',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.coolGray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Counters
                    if (state is UserManagementSuccess)
                      UserManagementCounters(users: state.users)
                    else if (state is UserManagementLoading)
                      const UserManagementCounters(users: [])
                    else
                      const UserManagementCounters(users: []),
                    const SizedBox(height: 20),

                    // Filters
                    UserManagementFilters(searchController: _searchController),
                    const SizedBox(height: 20),

                    // User Table
                    if (state is UserManagementLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state is UserManagementSuccess)
                      UserTable(users: state.users)
                    else if (state is UserManagementFailure)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.red500,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.error,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.coolGray700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const UserTable(users: []),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
