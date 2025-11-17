import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/secretary.dart';
import 'package:flutter/material.dart';

class SecretaryManagementSection extends StatelessWidget {
  const SecretaryManagementSection({
    required this.secretaries,
    required this.eventId,
    super.key,
  });

  final List<SecretaryInfo> secretaries;
  final int eventId;

  void _showAddSecretaryDialog(BuildContext context) {
    // TODO: Implement add secretary dialog (Chức năng 5)
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thư ký'),
        content: const Text(
          'Chức năng tìm kiếm và thêm thư ký đang được phát triển',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray900.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quản lý Thư ký', style: AppTextStyles.heading3),
              IconButton(
                icon: const Icon(Icons.add_moderator_rounded),
                onPressed: () => _showAddSecretaryDialog(context),
                tooltip: 'Thêm thư ký',
                color: AppColors.vkuBlue,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          if (secretaries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: AppColors.coolGray500,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text('Chưa có thư ký nào', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Text(
                      'Nhấn nút + để thêm thư ký',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: secretaries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final secretary = secretaries[index];
                return _SecretaryListItem(secretary: secretary);
              },
            ),
        ],
      ),
    );
  }
}

class _SecretaryListItem extends StatelessWidget {
  const _SecretaryListItem({required this.secretary});

  final SecretaryInfo secretary;

  String get _initials {
    final names = secretary.userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    }
    return secretary.userName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMD,
        vertical: AppSpacing.spaceXS,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.blue400.withOpacity(0.1),
        radius: 24,
        child: Text(
          _initials,
          style: AppTextStyles.heading5.copyWith(color: AppColors.blue400),
        ),
      ),
      title: Text(secretary.userName, style: AppTextStyles.heading5),
      subtitle: secretary.userEmail != null
          ? Text(secretary.userEmail!, style: AppTextStyles.bodySmall)
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline_rounded),
        color: AppColors.red500,
        onPressed: () {
          // TODO: Implement remove secretary
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng xóa thư ký đang được phát triển'),
            ),
          );
        },
      ),
    );
  }
}
