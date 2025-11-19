import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/admin/presentation/widgets/user_management_counters.dart';
import 'package:event_management/features/admin/presentation/widgets/user_management_filters.dart';
import 'package:event_management/features/admin/presentation/widgets/user_table.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8FAFC),
      child: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                const UserManagementCounters(
                  totalUsers: 88,
                  activeUsers: 87,
                  blockedUsers: 1,
                ),
                const SizedBox(height: 20),

                // Filters
                // TODO: Integrate with BLoC for filtering
                UserManagementFilters(searchController: _searchController),
                const SizedBox(height: 20),

                // User Table
                const UserTable(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
