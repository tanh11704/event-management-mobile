import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:flutter/material.dart';

/// Widget để tìm kiếm và chọn user làm manager
class UserSearchField extends StatefulWidget {
  const UserSearchField({
    required this.onUserSelected,
    required this.onUserRemoved,
    required this.selectedUsers,
    required this.allUsers,
    super.key,
  });

  final ValueChanged<UserEntity> onUserSelected;
  final ValueChanged<UserEntity> onUserRemoved;
  final List<UserEntity> selectedUsers;
  final List<UserEntity> allUsers;

  @override
  State<UserSearchField> createState() => _UserSearchFieldState();
}

class _UserSearchFieldState extends State<UserSearchField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<UserEntity> _filteredUsers = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.allUsers;
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(UserSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered users when allUsers changes
    if (oldWidget.allUsers != widget.allUsers) {
      final query = _searchController.text.toLowerCase().trim();
      setState(() {
        if (query.isEmpty) {
          _filteredUsers = widget.allUsers;
        } else {
          _filteredUsers = widget.allUsers.where((user) {
            return user.name.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query);
          }).toList();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = widget.allUsers;
      } else {
        _filteredUsers = widget.allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _filteredUsers.isNotEmpty;
    });
  }

  void _selectUser(UserEntity user) {
    // Always call the callback - let the Bloc handle duplicate checking
    widget.onUserSelected(user);
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Tìm kiếm người quản lý',
            hintText: 'Nhập tên hoặc email...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _focusNode.unfocus();
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_showSuggestions && _filteredUsers.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.spaceXS),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coolGray900.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final isSelected = widget.selectedUsers.any(
                  (u) => u.id == user.id,
                );
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.vkuBlue.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.vkuBlue),
                  ),
                  title: Text(
                    user.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(user.email, style: AppTextStyles.bodySmall),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.green500,
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _selectUser(user),
                        ),
                  onTap: () => _selectUser(user),
                );
              },
            ),
          ),
        if (widget.selectedUsers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceMD),
          Wrap(
            spacing: AppSpacing.spaceXS,
            runSpacing: AppSpacing.spaceXS,
            children: widget.selectedUsers.map((user) {
              return Chip(
                label: Text(user.name),
                avatar: CircleAvatar(
                  backgroundColor: AppColors.vkuBlue.withOpacity(0.1),
                  radius: 12,
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.vkuBlue,
                  ),
                ),
                onDeleted: () {
                  widget.onUserRemoved(user);
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
