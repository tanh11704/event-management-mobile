import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/ai_description_generator_dialog.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_html_editor.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_modern_text_field.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_request.dart';
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';

class EditEventBasicInfoSection extends StatefulWidget {
  const EditEventBasicInfoSection({
    required this.titleController,
    required this.descriptionHtml,
    required this.htmlEditorKey,
    required this.onDescriptionChanged,
    this.startDate,
    this.endDate,
    this.location,
    this.speakers,
    super.key,
  });

  final TextEditingController titleController;
  final String descriptionHtml;
  final GlobalKey htmlEditorKey;
  final ValueChanged<String> onDescriptionChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final List<String>? speakers;

  @override
  State<EditEventBasicInfoSection> createState() =>
      _EditEventBasicInfoSectionState();
}

class _EditEventBasicInfoSectionState extends State<EditEventBasicInfoSection> {
  bool _isGenerating = false;

  Future<void> _handleAiGenerate(GenerateDescriptionRequest request) async {
    if (widget.titleController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập tên sự kiện trước'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
      return;
    }

    if (widget.startDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn thời gian bắt đầu trước'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final repository = di.sl<EventRepository>();
      final fullRequest = GenerateDescriptionRequest(
        title: widget.titleController.text.trim(),
        location: widget.location,
        startTime: widget.startDate!.toUtc().toIso8601String(),
        endTime: widget.endDate?.toUtc().toIso8601String(),
        speakers: widget.speakers,
        additionalInfo: request.additionalInfo,
        tone: request.tone,
        length: request.length,
        target: request.target,
      );

      final response = await repository.generateDescription(fullRequest);

      if (mounted) {
        // Check if there's existing content
        final hasExistingContent = widget.descriptionHtml.trim().isNotEmpty;

        // Only show confirmation if user didn't choose to use existing content
        // (If they chose to use existing content, they already confirmed in the AI dialog)
        final isUsingExistingContent =
            request.additionalInfo != null &&
            request.additionalInfo!.contains(
              'Dựa trên nội dung mô tả hiện tại',
            );

        if (hasExistingContent && !isUsingExistingContent) {
          // Show confirmation dialog before overwriting
          final shouldOverwrite = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: AppColors.amber600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Xác nhận ghi đè',
                      style: AppTextStyles.heading4,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Bạn đã có nội dung mô tả hiện tại. Nội dung mới từ AI sẽ thay thế nội dung cũ. Bạn có muốn tiếp tục?',
                style: AppTextStyles.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Hủy',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.coolGray700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vkuBlue,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Ghi đè'),
                ),
              ],
            ),
          );

          if (shouldOverwrite != true) {
            // User cancelled, don't overwrite
            return;
          }
        }

        // Set the generated description to the HTML editor
        final editorState = widget.htmlEditorKey.currentState;
        if (editorState != null) {
          final dynamic state = editorState;
          if (state.setText != null) {
            await state.setText(response.description);
          }
        }
        widget.onDescriptionChanged(response.description);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasExistingContent
                  ? 'Đã cập nhật mô tả thành công!'
                  : 'Đã tạo mô tả thành công!',
            ),
            backgroundColor: AppColors.green500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showAiDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AiDescriptionGeneratorDialog(
        onGenerate: _handleAiGenerate,
        existingContent: widget.descriptionHtml,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditEventSectionHeader(title: 'Thông tin cơ bản'),
        EditEventModernTextField(
          controller: widget.titleController,
          label: 'Tên sự kiện',
          icon: Icons.event_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên sự kiện';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        Row(
          children: [
            const Expanded(child: EditEventSectionHeader(title: 'Mô tả')),
            OutlinedButton.icon(
              onPressed:
                  (_isGenerating ||
                      widget.titleController.text.trim().isEmpty ||
                      widget.startDate == null)
                  ? null
                  : _showAiDialog,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.vkuBlue,
                        ),
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                _isGenerating ? 'Đang tạo...' : 'Tạo với AI',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.vkuBlue,
                side: const BorderSide(color: AppColors.vkuBlue),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMD,
                  vertical: AppSpacing.spaceXS,
                ),
              ),
            ),
          ],
        ),
        EditEventHtmlEditor(
          key: widget.htmlEditorKey,
          initialValue: widget.descriptionHtml,
          onChanged: widget.onDescriptionChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả';
            }
            return null;
          },
        ),
      ],
    );
  }
}
