import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({required this.authRepository, super.key});

  final AuthRepository authRepository;

  void _showMenu(BuildContext context) {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (button == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: _MenuItem(
            icon: Icons.lock_reset_rounded,
            title: 'Đổi mật khẩu',
            onTap: () {
              Navigator.pop(context);
              appRouter.push(AppRoutes.changePassword);
            },
          ),
        ),
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: _MenuItem(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppSpacing.spaceXL),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.coolGray900.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated container
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceMD),
                decoration: const BoxDecoration(
                  color: AppColors.red100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.red500,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              Text(
                'Xác nhận đăng xuất',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.coolGray900,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceXM),
              Text(
                'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.coolGray700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceXL),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spaceMD,
                        ),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.heading5.copyWith(
                          color: AppColors.coolGray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMD),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red500,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spaceMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 20),
                          const SizedBox(width: AppSpacing.spaceXM),
                          Text(
                            'Đăng xuất',
                            style: AppTextStyles.heading5.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed ?? false) {
      try {
        await authRepository.logout();
        if (context.mounted) {
          appRouter.go(AppRoutes.login);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã xảy ra lỗi khi đăng xuất. Vui lòng thử lại.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showMenu(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.account_circle_rounded,
          color: AppColors.white,
          size: 28,
        ),
      ),
      tooltip: 'Menu người dùng',
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceMD,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.red500 : AppColors.vkuBlue,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDestructive
                      ? AppColors.red500
                      : AppColors.coolGray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
