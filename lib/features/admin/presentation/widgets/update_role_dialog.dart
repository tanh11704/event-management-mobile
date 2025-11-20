import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/admin/domain/entity/role_entity.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_bloc.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_event.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateRoleDialog extends StatefulWidget {
  const UpdateRoleDialog({required this.user, super.key});

  final UserEntity user;

  @override
  State<UpdateRoleDialog> createState() => _UpdateRoleDialogState();
}

class _UpdateRoleDialogState extends State<UpdateRoleDialog> {
  RoleEntity? _selectedRole;

  @override
  void initState() {
    super.initState();
    context.read<UserManagementBloc>().add(const UserManagementFetchRoles());
  }

  void _initializeSelectedRole(List<RoleEntity> roles) {
    if (widget.user.roles?.isNotEmpty ?? false) {
      final userRole = widget.user.roles!.first;
      _selectedRole = roles.firstWhere(
        (r) => r.id == userRole.id,
        orElse: () => roles.first,
      );
    } else {
      _selectedRole = roles.isNotEmpty ? roles.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserManagementSuccess && state.roles != null) {
          if (_selectedRole == null) {
            _initializeSelectedRole(state.roles!);
          }
        } else if (state is UserManagementSuccess && state.users.isNotEmpty) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật vai trò thành công'),
              backgroundColor: AppColors.green500,
            ),
          );
        } else if (state is UserManagementFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red500,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thay đổi vai trò cho ${widget.user.name}',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.coolGray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<UserManagementBloc, UserManagementState>(
                  builder: (context, state) {
                    if (state is UserManagementSuccess && state.roles != null) {
                      final roles = state.roles!;
                      if (_selectedRole == null && roles.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _initializeSelectedRole(roles);
                          setState(() {});
                        });
                      }
                      return DropdownButtonFormField<RoleEntity>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Vai trò',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.coolGray500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.vkuBlue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: roles.map((role) {
                          return DropdownMenuItem<RoleEntity>(
                            value: role,
                            child: Text(
                              role.displayName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.coolGray900,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      );
                    } else if (state is UserManagementFailure) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.red100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.red500,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.error,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.red500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.coolGray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    BlocBuilder<UserManagementBloc, UserManagementState>(
                      builder: (context, state) {
                        final isLoading = state is UserManagementLoading;
                        final hasRoles =
                            state is UserManagementSuccess &&
                            state.roles != null &&
                            state.roles!.isNotEmpty;
                        final isDisabled =
                            isLoading || !hasRoles || _selectedRole == null;
                        return ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () {
                                  if (_selectedRole != null) {
                                    context.read<UserManagementBloc>().add(
                                      UserManagementUpdateRole(
                                        userId: widget.user.id,
                                        roleId: _selectedRole!.id,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vkuBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Lưu',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
