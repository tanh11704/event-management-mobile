import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/widgets/user_menu.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class EventListAppBar extends StatelessWidget {
  const EventListAppBar({
    required this.tabController,
    required this.authRepository,
    super.key,
  });

  final TabController tabController;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.vkuBlue,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.spaceMD),
          child: UserMenu(authRepository: authRepository),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
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
                      _buildLiveBadge(),
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
            controller: tabController,
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
              _buildTab(
                icon: Icons.event_available_rounded,
                label: 'Tất cả sự kiện',
                index: 0,
              ),
              _buildTab(
                icon: Icons.manage_accounts_rounded,
                label: 'Sự kiện quản lý',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green500,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.green500.withOpacity(0.4),
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
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return Tab(
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, child) {
          final isSelected = tabController.index == index;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.vkuBlue
                    : AppColors.white.withOpacity(0.8),
              ),
              const SizedBox(width: AppSpacing.spaceXM),
              Text(label),
            ],
          );
        },
      ),
    );
  }
}
