import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_bloc.dart';
import 'package:event_management/features/admin/presentation/widgets/update_role_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTable extends StatelessWidget {
  const UserTable({required this.users, super.key});

  final List<UserEntity> users;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return _buildTableLayout();
        }
        return _buildCardLayout();
      },
    );
  }

  Widget _buildTableLayout() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.coolGray50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'HỌ TÊN',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray700,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ĐƠN VỊ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray700,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TRẠNG THÁI',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray700,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'VAI TRÒ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.coolGray700,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'HÀNH ĐỘNG',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: AppColors.coolGray500.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có người dùng nào',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.coolGray500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.coolGray500.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserRow(user: user);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCardLayout() {
    if (users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: AppColors.coolGray500.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Chưa có người dùng nào',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.coolGray500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserCard(user: user);
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.enabled ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Name & Email
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.coolGray900,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.coolGray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Unit
          Expanded(
            flex: 2,
            child: Text(
              user.unitName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.green500.withOpacity(0.1)
                    : AppColors.coolGray500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.green500
                          : AppColors.coolGray500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user.statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: isActive
                            ? AppColors.green500
                            : AppColors.coolGray700,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Role
          Expanded(
            flex: 2,
            child: Text(
              user.rolesText,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          SizedBox(
            width: 60,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.coolGray700,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 20,
                        color: AppColors.coolGray700,
                      ),
                      SizedBox(width: 12),
                      Text('Chỉnh sửa vai trò'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: AppColors.coolGray700,
                      ),
                      SizedBox(width: 12),
                      Text('Chỉnh sửa đơn vị'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: isActive ? 'block' : 'unblock',
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.block_rounded
                            : Icons.check_circle_rounded,
                        size: 20,
                        color: isActive ? AppColors.red500 : AppColors.green500,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isActive ? 'Khóa tài khoản' : 'Mở khóa',
                        style: TextStyle(
                          color: isActive
                              ? AppColors.red500
                              : AppColors.green500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'view') {
                  final bloc = context.read<UserManagementBloc>();
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => BlocProvider.value(
                      value: bloc,
                      child: UpdateRoleDialog(user: user),
                    ),
                  );
                } else if (value == 'edit') {
                  // TODO: Handle edit unit
                } else if (value == 'block' || value == 'unblock') {
                  // TODO: Handle block/unblock
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.enabled ?? false;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.coolGray900,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.coolGray500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.coolGray700,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 18,
                          color: AppColors.coolGray700,
                        ),
                        SizedBox(width: 12),
                        Text('Chỉnh sửa vai trò'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: AppColors.coolGray700,
                        ),
                        SizedBox(width: 12),
                        Text('Chỉnh sửa đơn vị'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: isActive ? 'block' : 'unblock',
                    child: Row(
                      children: [
                        Icon(
                          isActive
                              ? Icons.block_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: isActive
                              ? AppColors.red500
                              : AppColors.green500,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isActive ? 'Khóa tài khoản' : 'Mở khóa',
                          style: TextStyle(
                            color: isActive
                                ? AppColors.red500
                                : AppColors.green500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'view') {
                    final bloc = context.read<UserManagementBloc>();
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: bloc,
                        child: UpdateRoleDialog(user: user),
                      ),
                    );
                  } else if (value == 'edit') {
                    // TODO: Handle edit unit
                  } else if (value == 'block' || value == 'unblock') {
                    // TODO: Handle block/unblock
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.business_rounded, label: user.unitName),
              _InfoChip(icon: Icons.badge_rounded, label: user.rolesText),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.green500.withOpacity(0.1)
                      : AppColors.coolGray500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.green500
                            : AppColors.coolGray500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: isActive
                            ? AppColors.green500
                            : AppColors.coolGray700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coolGray50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.coolGray500),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
