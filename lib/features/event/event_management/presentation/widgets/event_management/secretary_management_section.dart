import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/shared/data/models/event_manager_info.dart';
import 'package:event_management/features/event/shared/data/models/participant.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/secretary_management/secretary_management_bloc.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/secretary_management/secretary_management_event.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/secretary_management/secretary_management_state.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/add_secretary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecretaryManagementSection extends StatefulWidget {
  const SecretaryManagementSection({
    required this.eventId,
    required this.participants,
    super.key,
  });

  final int eventId;
  final List<ParticipantInfo> participants;

  @override
  State<SecretaryManagementSection> createState() =>
      _SecretaryManagementSectionState();
}

class _SecretaryManagementSectionState
    extends State<SecretaryManagementSection> {
  /// Enriches EventManagerInfo with user information from participants list.
  List<EventManagerInfo> _enrichManagersWithParticipants(
    List<EventManagerInfo> managers,
  ) {
    // Create a map of userId -> ParticipantInfo for quick lookup
    final participantMap = {
      for (final participant in widget.participants)
        participant.userId: participant,
    };

    // Enrich each manager with participant information
    return managers.map((manager) {
      final participant = participantMap[manager.userId];
      if (participant != null) {
        // Always enrich with participant info if found
        return manager.copyWith(
          userName: participant.userName,
          userEmail: participant.userEmail,
        );
      }
      return manager;
    }).toList();
  }

  void _showAddSecretaryDialog(BuildContext context) {
    // Get the bloc instance before opening dialog
    final bloc = context.read<SecretaryManagementBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AddSecretaryDialog(
          eventId: widget.eventId,
          participants: widget.participants,
          onSecretaryAdded: () {
            // Refresh the list after adding
            bloc.add(SecretaryManagementRefresh(eventId: widget.eventId));
          },
        ),
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    EventManagerInfo secretary,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa thư ký "${secretary.userName}" khỏi sự kiện này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SecretaryManagementBloc>().add(
                SecretaryManagementRemoveSecretary(
                  eventId: widget.eventId,
                  userId: secretary.userId,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SecretaryManagementBloc>()
        ..add(SecretaryManagementFetchEventManagers(eventId: widget.eventId)),
      child: BlocConsumer<SecretaryManagementBloc, SecretaryManagementState>(
        listener: (context, state) {
          if (state is SecretaryManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.red500,
              ),
            );
          } else if (state is SecretaryManagementAssignSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.green500,
              ),
            );
          } else if (state is SecretaryManagementRemoveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.green500,
              ),
            );
          }
        },
        builder: (context, state) {
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
                      onPressed: state is SecretaryManagementLoading
                          ? null
                          : () => _showAddSecretaryDialog(context),
                      tooltip: 'Thêm thư ký',
                      color: AppColors.vkuBlue,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                if (state is SecretaryManagementLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.spaceLG),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is SecretaryManagementSuccess)
                  _buildSecretaryList(
                    context,
                    _enrichManagersWithParticipants(state.staffMembers),
                  )
                else if (state is SecretaryManagementError)
                  _buildErrorState(context)
                else
                  _buildEmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecretaryList(
    BuildContext context,
    List<EventManagerInfo> secretaries,
  ) {
    if (secretaries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: secretaries.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final secretary = secretaries[index];
        return _SecretaryListItem(
          secretary: secretary,
          onRemove: () => _showRemoveConfirmation(context, secretary),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
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
            Text('Nhấn nút + để thêm thư ký', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.red500,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            Text('Có lỗi xảy ra', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.spaceXS),
            ElevatedButton(
              onPressed: () {
                context.read<SecretaryManagementBloc>().add(
                  SecretaryManagementRefresh(eventId: widget.eventId),
                );
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecretaryListItem extends StatelessWidget {
  const _SecretaryListItem({required this.secretary, required this.onRemove});

  final EventManagerInfo secretary;
  final VoidCallback onRemove;

  String get _initials {
    final name = secretary.userName ?? 'U';
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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
      title: Text(
        secretary.userName ?? 'User #${secretary.userId}',
        style: AppTextStyles.heading5,
      ),
      subtitle: secretary.userEmail != null
          ? Text(secretary.userEmail!, style: AppTextStyles.bodySmall)
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline_rounded),
        color: AppColors.red500,
        onPressed: onRemove,
        tooltip: 'Xóa thư ký',
      ),
    );
  }
}
