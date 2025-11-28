import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/poll/data/models/export_format.dart';
import 'package:event_management/features/poll/data/models/poll_stats_response.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_bloc.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_event.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PollStatsDialog extends StatelessWidget {
  const PollStatsDialog({
    required this.pollId,
    required this.eventId,
    super.key,
  });

  final int pollId;
  final int eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<PollStatsBloc>()..add(PollStatsFetched(eventId)),
      child: BlocBuilder<PollStatsBloc, PollStatsState>(
        builder: (context, state) {
          PollStatsResponse? pollStats;
          if (state is PollStatsSuccess) {
            pollStats = state.stats.firstWhere(
              (s) => s.id == pollId,
              orElse: () => state.stats.first,
            );
          }

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: AppColors.vkuBlue),
                const SizedBox(width: AppSpacing.spaceXS),
                const Text('Thống kê Poll'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: state is PollStatsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is PollStatsError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.red500,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),
                        Text(state.message, textAlign: TextAlign.center),
                      ],
                    )
                  : pollStats == null
                  ? const Text('Không tìm thấy thống kê')
                  : Builder(
                      builder: (context) {
                        final stats = pollStats!;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(stats.title, style: AppTextStyles.heading4),
                              const SizedBox(height: AppSpacing.spaceMD),
                              Row(
                                children: [
                                  _StatCard(
                                    icon: Icons.people,
                                    label: 'Người bỏ phiếu',
                                    value: '${stats.totalVoters}',
                                  ),
                                  const SizedBox(width: AppSpacing.spaceMD),
                                  _StatCard(
                                    icon: Icons.how_to_vote,
                                    label: 'Tổng số phiếu',
                                    value: '${stats.totalVotes}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.spaceLG),
                              const Divider(),
                              const SizedBox(height: AppSpacing.spaceMD),
                              Text('Kết quả:', style: AppTextStyles.heading5),
                              const SizedBox(height: AppSpacing.spaceMD),
                              ...stats.options.map((option) {
                                final totalVotes = stats.totalVotes;
                                final percentage = totalVotes > 0
                                    ? (option.voteCount / totalVotes * 100)
                                          .toStringAsFixed(1)
                                    : '0.0';
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.spaceMD,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option.text,
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                          ),
                                          Text(
                                            '$percentage%',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: AppSpacing.spaceXS,
                                      ),
                                      LinearProgressIndicator(
                                        value: totalVotes > 0
                                            ? option.voteCount / totalVotes
                                            : 0,
                                        backgroundColor: AppColors.coolGray50,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.vkuBlue,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${option.voteCount} phiếu',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.coolGray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: state is PollStatsSuccess && pollStats != null
                ? [
                    OutlinedButton.icon(
                      onPressed: () => _handleExport(context, pollStats!),
                      icon: const Icon(Icons.file_download_rounded),
                      label: const Text('Xuất báo cáo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.vkuBlue,
                        side: const BorderSide(color: AppColors.vkuBlue),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceXS),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vkuBlue,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Đóng'),
                    ),
                  ]
                : [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vkuBlue,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Đóng'),
                    ),
                  ],
          );
        },
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    PollStatsResponse pollStats,
  ) async {
    // Show loading dialog
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.spaceLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.spaceMD),
                Text('Đang xuất báo cáo...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final repository = di.sl<PollRepository>();
      final bytes = await repository.exportPollStats(
        pollId,
        ExportFormat.excel,
      );

      if (bytes.isEmpty) {
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        if (!context.mounted) return;
        _showErrorSnackBar(context, 'Server trả về dữ liệu rỗng.');
        return;
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'ket_qua_poll_${pollStats.id}_$timestamp.xlsx';
      final filePath = path.join(directory.path, filename);

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (!context.mounted) return;
      _showSuccessDialog(context, filePath, filename);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      if (!context.mounted) return;
      _showErrorSnackBar(
        context,
        'Không thể xuất báo cáo: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  void _showSuccessDialog(
    BuildContext context,
    String filePath,
    String filename,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.green500),
            SizedBox(width: AppSpacing.spaceXS),
            Text('Xuất báo cáo thành công'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File đã được lưu tại:', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              filename,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray500,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await OpenFilex.open(filePath);
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Mở file'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vkuBlue,
              foregroundColor: AppColors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Lưu context trước khi pop dialog
              final navigatorContext = Navigator.of(dialogContext);

              if (Platform.isIOS) {
                // iOS: Share trước, sau đó pop dialog
                await _shareFile(dialogContext, filePath);
                if (dialogContext.mounted) {
                  navigatorContext.pop();
                }
              } else {
                // Android: Pop dialog trước, sau đó share
                navigatorContext.pop();
                // Lấy context từ parent sau khi pop
                await Future<void>.delayed(const Duration(milliseconds: 100));
                if (context.mounted) {
                  await _shareFile(context, filePath);
                }
              }
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text('Chia sẻ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vkuBlue,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile(BuildContext context, String filePath) async {
    if (kDebugMode) {
      debugPrint('📂 ========== DEBUG SHARE FILE ==========');
      debugPrint('📂 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      debugPrint('📂 File path: $filePath');
    }

    try {
      // Kiểm tra file có tồn tại không (đơn giản và nhanh)
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File không tồn tại tại đường dẫn: $filePath');
      }

      // Tạo XFile ngay lập tức
      final xFile = XFile(filePath);
      if (kDebugMode) {
        debugPrint('📂 XFile created: ${xFile.path}');
        debugPrint('📂 Đang gọi Share.shareXFiles...');
      }

      // Xử lý đặc biệt cho iOS
      if (Platform.isIOS) {
        // Sử dụng addPostFrameCallback để đảm bảo UI đã render xong
        // và chỉ delay tối thiểu
        await Future<void>.delayed(const Duration(milliseconds: 50));

        if (!context.mounted) return;

        // Tìm RenderBox để tính sharePositionOrigin (chỉ khi cần)
        Rect? shareOrigin;
        try {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) {
            final offset = box.localToGlobal(Offset.zero);
            shareOrigin = Rect.fromLTWH(
              offset.dx,
              offset.dy,
              box.size.width,
              box.size.height / 2,
            );
          }
        } catch (_) {
          // Nếu không tìm được RenderBox, shareOrigin sẽ là null
          // Share sheet sẽ hiển thị ở vị trí mặc định
        }

        await Share.shareXFiles(
          [xFile],
          text: 'Kết quả poll',
          sharePositionOrigin: shareOrigin,
        );
      } else {
        // Android: share trực tiếp
        await Share.shareXFiles([xFile], text: 'Kết quả poll');
      }

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

      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Không thể chia sẻ file: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.red500,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.blue50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.vkuBlue, size: 24),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(color: AppColors.vkuBlue),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.coolGray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
