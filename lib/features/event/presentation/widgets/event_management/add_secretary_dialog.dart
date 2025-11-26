import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/secretary_management/secretary_management_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/secretary_management/secretary_management_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dialog for adding a secretary (staff) to an event.
class AddSecretaryDialog extends StatefulWidget {
  const AddSecretaryDialog({
    required this.eventId,
    required this.participants,
    required this.onSecretaryAdded,
    super.key,
  });

  final int eventId;
  final List<ParticipantInfo> participants;
  final VoidCallback onSecretaryAdded;

  @override
  State<AddSecretaryDialog> createState() => _AddSecretaryDialogState();
}

class _AddSecretaryDialogState extends State<AddSecretaryDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ParticipantInfo> _availableParticipants = [];
  List<ParticipantInfo> _filteredParticipants = [];
  bool _isLoadingParticipants = true;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableParticipants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableParticipants() async {
    setState(() {
      _isLoadingParticipants = true;
    });

    try {
      final eventRepository = di.sl<EventRepository>();

      // Get existing managers/staff to filter out
      final existingManagers = await eventRepository.getEventManagers(
        widget.eventId,
      );
      final existingUserIds = existingManagers.map((m) => m.userId).toSet();

      // Filter participants: only those who are not already managers/staff
      setState(() {
        _availableParticipants = widget.participants
            .where(
              (participant) => !existingUserIds.contains(participant.userId),
            )
            .toList();
        _filteredParticipants = _availableParticipants;
        _isLoadingParticipants = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingParticipants = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách người tham gia: $e'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredParticipants = _availableParticipants;
      } else {
        _filteredParticipants = _availableParticipants.where((participant) {
          final name = participant.userName.toLowerCase();
          final email = participant.userEmail?.toLowerCase() ?? '';
          return name.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _assignSecretary(ParticipantInfo participant) async {
    setState(() {
      _isAssigning = true;
    });

    try {
      final authRepository = di.sl<AuthRepository>();
      final currentUser = await authRepository.getAuthUser();
      final currentUserId = currentUser.id;

      // Add to BLoC
      if (mounted) {
        context.read<SecretaryManagementBloc>().add(
          SecretaryManagementAssignSecretary(
            eventId: widget.eventId,
            userId: participant.userId,
            assignedBy: currentUserId,
          ),
        );
      }

      // Call callback
      widget.onSecretaryAdded();

      // Close dialog after a short delay
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _isAssigning = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể thêm thư ký: $e'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Thêm Thư ký', style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                hintStyle: AppTextStyles.bodyMedium,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.coolGray500,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: _searchController.clear,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.coolGray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            if (_isLoadingParticipants)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filteredParticipants.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.coolGray500,
                      ),
                      const SizedBox(height: AppSpacing.spaceMD),
                      Text(
                        _availableParticipants.isEmpty
                            ? 'Tất cả người tham gia đã được gán làm thư ký'
                            : 'Không tìm thấy người tham gia',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredParticipants.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final participant = _filteredParticipants[index];
                    final name = participant.userName;
                    final email = participant.userEmail ?? 'Chưa có email';
                    final initials = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : 'U';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.vkuBlue.withOpacity(0.1),
                        child: Text(
                          initials,
                          style: AppTextStyles.heading5.copyWith(
                            color: AppColors.vkuBlue,
                          ),
                        ),
                      ),
                      title: Text(name, style: AppTextStyles.heading5),
                      subtitle: Text(email, style: AppTextStyles.bodySmall),
                      trailing: _isAssigning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.add_circle_rounded),
                              color: AppColors.vkuBlue,
                              onPressed: () => _assignSecretary(participant),
                              tooltip: 'Thêm làm thư ký',
                            ),
                      onTap: _isAssigning
                          ? null
                          : () => _assignSecretary(participant),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
