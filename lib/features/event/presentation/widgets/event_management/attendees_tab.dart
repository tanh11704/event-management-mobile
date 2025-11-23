import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class AttendeesTab extends StatefulWidget {
  const AttendeesTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  State<AttendeesTab> createState() => _AttendeesTabState();
}

class _AttendeesTabState extends State<AttendeesTab> {
  String _searchQuery = '';
  AttendeeFilter _selectedFilter = AttendeeFilter.all;
  bool _isExporting = false;

  late final EventRepository _eventRepository;

  @override
  void initState() {
    super.initState();
    _eventRepository = di.sl<EventRepository>();
  }

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

  String _getFilterString(AttendeeFilter filter) {
    switch (filter) {
      case AttendeeFilter.all:
        return 'all';
      case AttendeeFilter.checkedIn:
        return 'checked_in';
      case AttendeeFilter.notCheckedIn:
        return 'not_checked_in';
    }
  }

  Future<void> _shareFile(BuildContext context, String filePath) async {
    if (kDebugMode) {
      debugPrint('📂 ========== DEBUG SHARE FILE ==========');
      debugPrint('📂 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      debugPrint('📂 File path: $filePath');
    }

    try {
      // Bước 1: Kiểm tra file có tồn tại không
      final file = File(filePath);
      final fileExists = await file.exists();

      if (kDebugMode) {
        debugPrint('📂 File exists: $fileExists');
      }

      if (!fileExists) {
        if (kDebugMode) {
          debugPrint('❌ File không tồn tại tại đường dẫn: $filePath');
        }
        throw Exception('File không tồn tại tại đường dẫn: $filePath');
      }

      // Bước 2: Kiểm tra file size và permissions
      final fileStat = await file.stat();
      if (kDebugMode) {
        debugPrint(
          '📂 File size: ${fileStat.size} bytes (${(fileStat.size / 1024).toStringAsFixed(2)} KB)',
        );
        debugPrint('📂 File mode: ${fileStat.mode}');
        debugPrint('📂 File modified: ${fileStat.modified}');
        debugPrint('📂 Is file: ${fileStat.type == FileSystemEntityType.file}');
      }

      // Bước 3: Kiểm tra có thể đọc file không
      final canRead =
          await file.exists() &&
          await file.readAsBytes().then((_) => true).catchError((_) => false);
      if (kDebugMode) {
        debugPrint('📂 Can read file: $canRead');
      }

      if (!canRead) {
        if (kDebugMode) {
          debugPrint('❌ Không thể đọc file');
        }
        throw Exception('Không thể đọc file');
      }

      // Bước 4: Tạo XFile và kiểm tra RenderBox
      final xFile = XFile(filePath);
      if (kDebugMode) {
        debugPrint('📂 XFile created: ${xFile.path}');
        debugPrint('📂 XFile name: ${xFile.name}');
        debugPrint('📂 XFile mimeType: ${xFile.mimeType}');
      }

      // FIX: Kiểm tra RenderBox kỹ hơn
      final box = context.findRenderObject() as RenderBox?;

      Rect? shareOrigin;
      if (box != null && box.hasSize) {
        // Chỉ lấy 1/2 màn hình phía dưới để an toàn cho iPad
        final offset = box.localToGlobal(Offset.zero);
        shareOrigin = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          box.size.width,
          box.size.height / 2,
        );
        if (kDebugMode) {
          debugPrint('📂 Share origin: $shareOrigin');
        }
      } else {
        if (kDebugMode) {
          debugPrint('📂 RenderBox không có size, shareOrigin = null');
        }
      }

      // Bước 5: Gọi Share
      if (kDebugMode) {
        debugPrint('📂 Đang gọi Share.shareXFiles...');
      }

      await Share.shareXFiles(
        [xFile],
        text: 'Danh sách người tham gia sự kiện',
        // FIX: Cung cấp vị trí chính xác hơn
        sharePositionOrigin: shareOrigin,
      );

      if (kDebugMode) {
        debugPrint('✅ Share dialog đã đóng/hoàn tất');
        debugPrint('📂 ========== END DEBUG ==========');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi khi gọi Share: $e');
        debugPrint('❌ Stack trace:');
        debugPrint(stack.toString());
        debugPrint('📂 ========== END DEBUG ==========');
      }
      rethrow;
    }
  }

  Future<void> _exportAndShareParticipants(BuildContext context) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    // SnackBar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            SizedBox(width: AppSpacing.spaceMD),
            Text('Đang xuất file Excel...'),
          ],
        ),
        backgroundColor: AppColors.vkuBlue,
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final filter = _getFilterString(_selectedFilter);

      if (kDebugMode) {
        debugPrint(
          '📤 AttendeesTab: Gọi exportParticipants cho event ${widget.eventDetail.id} với filter $filter',
        );
      }

      final filePath = await _eventRepository.exportParticipants(
        eventId: widget.eventDetail.id,
        filter: filter,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();

      if (Platform.isIOS) {
        // Đợi UI ổn định chút rồi share
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;
          await Future<void>.delayed(const Duration(milliseconds: 300));

          final overlay = Overlay.of(context);
          final shareContext = overlay.context;
          await _shareFile(shareContext, filePath);
        });
      } else {
        // Android: hiển thị SnackBar với nút MỞ NGAY
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Xuất file Excel thành công!'),
            backgroundColor: AppColors.green500,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'MỞ NGAY',
              textColor: AppColors.white,
              onPressed: () => _shareFile(context, filePath),
            ),
          ),
        );
      }
    } catch (e, stack) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất file: $e'),
          backgroundColor: AppColors.red500,
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ AttendeesTab: Lỗi exportParticipants: $e');
        debugPrint(stack.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventDetailBloc, EventDetailState>(
      listenWhen: (previous, current) {
        // Chỉ lắng nghe các state liên quan import
        final shouldListen =
            current is EventDetailImportSuccess ||
            current is EventDetailImportFailure;

        return shouldListen;
      },
      listener: (context, state) {
        // Import success/failure
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
        body: Column(
          children: [
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
                      isSelected: _selectedFilter == AttendeeFilter.checkedIn,
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
        ),
        floatingActionButton: _SpeedDialFab(
          onExportExcel: _isExporting
              ? null
              : () {
                  _exportAndShareParticipants(context);
                },
          onInviteByFile: _isExporting
              ? null
              : () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls', 'csv'],
                  );

                  if (result != null && context.mounted) {
                    final file = result.files.single;
                    context.read<EventDetailBloc>().add(
                      EventDetailImportParticipants(
                        eventId: widget.eventDetail.id,
                        file: file.xFile,
                      ),
                    );
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

  final VoidCallback? onExportExcel;
  final VoidCallback? onInviteByFile;

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
                  backgroundColor: widget.onExportExcel == null
                      ? AppColors.coolGray500
                      : AppColors.green500,
                  icon: widget.onExportExcel == null
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
                      : const Icon(Icons.download_rounded),
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
                  backgroundColor: widget.onInviteByFile == null
                      ? AppColors.coolGray500
                      : AppColors.blue400,
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
