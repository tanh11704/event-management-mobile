import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendeesTab extends StatefulWidget {
  const AttendeesTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  State<AttendeesTab> createState() => _AttendeesTabState();
}

class _AttendeesTabState extends State<AttendeesTab> {
  String _searchQuery = '';
  AttendeeFilter _selectedFilter = AttendeeFilter.all;

  List<ParticipantInfo> get _filteredParticipants {
    var filtered = widget.eventDetail.participants;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final query = _searchQuery.toLowerCase();
        return p.userName.toLowerCase().contains(query) ||
            (p.userEmail?.toLowerCase().contains(query) ?? false) ||
            (p.userPhone?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case AttendeeFilter.all:
        break;
      case AttendeeFilter.checkedIn:
        filtered = filtered.where((p) => p.isCheckedIn ?? false).toList();
      case AttendeeFilter.notCheckedIn:
        filtered = filtered.where((p) => p.isCheckedIn != true).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventDetailBloc, EventDetailState>(
      listener: (context, state) {
        if (state is EventDetailImportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.green500,
            ),
          );
        } else if (state is EventDetailImportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red500,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.coolGray50,
        body: BlocBuilder<EventDetailBloc, EventDetailState>(
          builder: (context, state) {
            return Column(
              children: [
                // Import Progress Banner
                if (state is EventDetailImporting)
                  _ImportProgressBanner(state: state),
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spaceMD),
                  color: AppColors.white,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email, số điện thoại...',
                      hintStyle: AppTextStyles.bodyMedium,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.coolGray500,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.coolGray50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceMD,
                        vertical: AppSpacing.spaceMD,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMD,
                    vertical: AppSpacing.spaceXM,
                  ),
                  color: AppColors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Tất cả',
                          isSelected: _selectedFilter == AttendeeFilter.all,
                          onTap: () {
                            setState(() {
                              _selectedFilter = AttendeeFilter.all;
                            });
                          },
                        ),
                        const SizedBox(width: AppSpacing.spaceXM),
                        _FilterChip(
                          label: 'Đã check-in',
                          isSelected:
                              _selectedFilter == AttendeeFilter.checkedIn,
                          onTap: () {
                            setState(() {
                              _selectedFilter = AttendeeFilter.checkedIn;
                            });
                          },
                        ),
                        const SizedBox(width: AppSpacing.spaceXM),
                        _FilterChip(
                          label: 'Chưa check-in',
                          isSelected:
                              _selectedFilter == AttendeeFilter.notCheckedIn,
                          onTap: () {
                            setState(() {
                              _selectedFilter = AttendeeFilter.notCheckedIn;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Attendees List
                Expanded(
                  child: _filteredParticipants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: AppColors.coolGray500,
                              ),
                              const SizedBox(height: AppSpacing.spaceMD),
                              Text(
                                'Không tìm thấy người tham dự',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.spaceMD),
                          itemCount: _filteredParticipants.length,
                          itemBuilder: (context, index) {
                            final participant = _filteredParticipants[index];
                            return _AttendeeListItem(participant: participant);
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: _SpeedDialFab(
          onExportExcel: () {
            // TODO: Implement export Excel (Chức năng 7)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng xuất Excel đang được phát triển'),
              ),
            );
          },
          onInviteByFile: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xlsx', 'xls', 'csv'],
            );

            if (result != null) {
              final file = result.files.single;
              if (context.mounted) {
                context.read<EventDetailBloc>().add(
                  EventDetailImportParticipants(
                    eventId: widget.eventDetail.id,
                    file: file.xFile,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

enum AttendeeFilter { all, checkedIn, notCheckedIn }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceXM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vkuBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.vkuBlue : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.coolGray700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AttendeeListItem extends StatelessWidget {
  const _AttendeeListItem({required this.participant});

  final ParticipantInfo participant;

  String get _initials {
    final names = participant.userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    }
    return participant.userName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = participant.isCheckedIn ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceMD),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.spaceMD),
        leading: CircleAvatar(
          backgroundColor: AppColors.vkuBlue.withOpacity(0.1),
          radius: 24,
          child: Text(
            _initials,
            style: AppTextStyles.heading5.copyWith(color: AppColors.vkuBlue),
          ),
        ),
        title: Text(participant.userName, style: AppTextStyles.heading5),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (participant.userEmail != null) ...[
              const SizedBox(height: AppSpacing.spaceXS),
              Text(participant.userEmail!, style: AppTextStyles.bodySmall),
            ],
            if (participant.userPhone != null) ...[
              const SizedBox(height: AppSpacing.spaceXS),
              Text(participant.userPhone!, style: AppTextStyles.bodySmall),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceXM,
            vertical: AppSpacing.spaceXS,
          ),
          decoration: BoxDecoration(
            color: isCheckedIn ? AppColors.green50 : AppColors.coolGray50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCheckedIn
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                color: isCheckedIn ? AppColors.green500 : AppColors.coolGray500,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.spaceXS),
              Text(
                isCheckedIn ? 'Đã check-in' : 'Chưa',
                style: AppTextStyles.caption.copyWith(
                  color: isCheckedIn
                      ? AppColors.green500
                      : AppColors.coolGray500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedDialFab extends StatefulWidget {
  const _SpeedDialFab({
    required this.onExportExcel,
    required this.onInviteByFile,
  });

  final VoidCallback onExportExcel;
  final VoidCallback onInviteByFile;

  @override
  State<_SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<_SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Export Excel
        if (_isExpanded)
          FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceMD),
                child: FloatingActionButton.extended(
                  heroTag: 'export_excel',
                  onPressed: widget.onExportExcel,
                  backgroundColor: AppColors.green500,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Xuất Excel'),
                ),
              ),
            ),
          ),

        // Invite by File
        if (_isExpanded)
          FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceMD),
                child: FloatingActionButton.extended(
                  heroTag: 'invite_file',
                  onPressed: widget.onInviteByFile,
                  backgroundColor: AppColors.blue400,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Mời bằng file'),
                ),
              ),
            ),
          ),

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          backgroundColor: AppColors.vkuBlue,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _ImportProgressBanner extends StatelessWidget {
  const _ImportProgressBanner({required this.state});

  final EventDetailImporting state;

  String get _statusText {
    switch (state.status?.toUpperCase()) {
      case 'PENDING':
        return 'Đang chờ xử lý...';
      case 'PROCESSING':
        return 'Đang xử lý...';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'FAILED':
        return 'Thất bại';
      default:
        return 'Đang xử lý...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = state.progress.clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray900.withOpacity(0.1),
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
              const Icon(
                Icons.upload_file_rounded,
                color: AppColors.vkuBlue,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.spaceXM),
              Expanded(
                child: Text(
                  'Đang import người tham gia',
                  style: AppTextStyles.heading5.copyWith(
                    color: AppColors.coolGray900,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.vkuBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXM),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // Show indeterminate when progress is 0 or totalRecords is null
              value: (progress > 0 && state.totalRecords != null)
                  ? progress
                  : null,
              backgroundColor: AppColors.coolGray50,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.status?.toUpperCase() == 'FAILED'
                    ? AppColors.red500
                    : AppColors.vkuBlue,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusText,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray500,
                ),
              ),
              Text(
                state.processedCount != null && state.totalRecords != null
                    ? '${state.processedCount}/${state.totalRecords} đã xử lý'
                    : state.totalRecords != null
                    ? '0/${state.totalRecords} đã xử lý'
                    : 'Đang khởi tạo...',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
