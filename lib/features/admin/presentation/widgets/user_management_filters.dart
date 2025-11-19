import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class UserManagementFilters extends StatelessWidget {
  const UserManagementFilters({required this.searchController, super.key});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.coolGray50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      // TODO: Dispatch search event to BLoC
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.coolGray500,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.coolGray500,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // TODO: Dispatch filter action to BLoC
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.coolGray50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.coolGray700,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // TODO: Dispatch refresh event to BLoC
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.coolGray50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: AppColors.coolGray700,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
