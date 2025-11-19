import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class UserManagementCounters extends StatelessWidget {
  const UserManagementCounters({
    required this.totalUsers,
    required this.activeUsers,
    required this.blockedUsers,
    super.key,
  });

  final int totalUsers;
  final int activeUsers;
  final int blockedUsers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _CounterCard(
                  title: 'Tổng số tài khoản',
                  count: totalUsers,
                  icon: Icons.groups_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CounterCard(
                  title: 'Đang hoạt động',
                  count: activeUsers,
                  icon: Icons.check_circle_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CounterCard(
                  title: 'Đã khóa',
                  count: blockedUsers,
                  icon: Icons.block_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _CounterCard(
              title: 'Tổng số tài khoản',
              count: totalUsers,
              icon: Icons.groups_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            const SizedBox(height: 12),
            _CounterCard(
              title: 'Đang hoạt động',
              count: activeUsers,
              icon: Icons.check_circle_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            const SizedBox(height: 12),
            _CounterCard(
              title: 'Đã khóa',
              count: blockedUsers,
              icon: Icons.block_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
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

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final int count;
  final IconData icon;
  final LinearGradient gradient;

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.coolGray500,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.coolGray900,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
