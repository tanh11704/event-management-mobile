import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

// TODO: Replace with actual User model from domain layer
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.unit,
    required this.role,
    required this.status,
  });
  final String id;
  final String name;
  final String email;
  final String unit;
  final String role;
  final String status;
}

class UserTable extends StatelessWidget {
  const UserTable({super.key});

  // TODO: Replace with actual data from BLoC/API
  List<User> get _mockUsers => [
    const User(
      id: '1',
      name: 'Super Admin',
      email: 'admin@yourapp.com',
      unit: 'Chưa có',
      role: 'Quản trị viên',
      status: 'Hoạt động',
    ),
    const User(
      id: '2',
      name: 'Trần Phước Anh',
      email: 'anhtp.22it@vku.udn.vn',
      unit: 'Chưa có',
      role: 'Người dùng',
      status: 'Hoạt động',
    ),
    const User(
      id: '3',
      name: 'Trần Phước Anh',
      email: 'tanhi1704@gmail.com',
      unit: 'Chưa có',
      role: 'Người dùng',
      status: 'Hoạt động',
    ),
    const User(
      id: '4',
      name: 'test',
      email: 'test@gmail.com',
      unit: 'Chưa có',
      role: 'Người dùng',
      status: 'Đã khóa',
    ),
    const User(
      id: '5',
      name: 'Nguyễn Minh Nhật',
      email: 'nhatnguyen389@gmail.com',
      unit: 'Chưa có',
      role: 'Người dùng',
      status: 'Hoạt động',
    ),
  ];

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockUsers.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.coolGray500.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final user = _mockUsers[index];
              return _UserRow(user: user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mockUsers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _mockUsers[index];
        return _UserCard(user: user);
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'Hoạt động';

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
              user.unit,
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
                      user.status,
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
              user.role,
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
                // TODO: Handle action
                print('Action: $value for user ${user.id}');
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

  final User user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'Hoạt động';

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
                  // TODO: Handle action
                  print('Action: $value for user ${user.id}');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.business_rounded, label: user.unit),
              _InfoChip(icon: Icons.badge_rounded, label: user.role),
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
                      user.status,
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
