import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_request.dart';
import 'package:flutter/material.dart';

class AiDescriptionGeneratorDialog extends StatefulWidget {
  const AiDescriptionGeneratorDialog({
    required this.onGenerate,
    this.existingContent,
    super.key,
  });

  final Future<void> Function(GenerateDescriptionRequest request) onGenerate;
  final String? existingContent;

  @override
  State<AiDescriptionGeneratorDialog> createState() =>
      _AiDescriptionGeneratorDialogState();
}

class _AiDescriptionGeneratorDialogState
    extends State<AiDescriptionGeneratorDialog> {
  ContentTone _selectedTone = ContentTone.friendly;
  ContentLength _selectedLength = ContentLength.medium;
  ContentTarget _selectedTarget = ContentTarget.general;
  final TextEditingController _additionalInfoController =
      TextEditingController();
  bool _isGenerating = false;
  bool _useExistingContent = false;

  String _getToneLabel(ContentTone tone) {
    switch (tone) {
      case ContentTone.professional:
        return 'Chuyên nghiệp';
      case ContentTone.friendly:
        return 'Thân thiện';
      case ContentTone.exciting:
        return 'Hào hứng';
      case ContentTone.formal:
        return 'Trang trọng';
      case ContentTone.casual:
        return 'Thân mật';
    }
  }

  String _getLengthLabel(ContentLength length) {
    switch (length) {
      case ContentLength.short:
        return 'Ngắn (50-100 từ)';
      case ContentLength.medium:
        return 'Trung bình (100-200 từ)';
      case ContentLength.long:
        return 'Dài (200-300 từ)';
    }
  }

  String _getTargetLabel(ContentTarget target) {
    switch (target) {
      case ContentTarget.website:
        return 'Website';
      case ContentTarget.facebook:
        return 'Facebook';
      case ContentTarget.email:
        return 'Email marketing';
      case ContentTarget.general:
        return 'Tổng quát';
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  String _stripHtmlTags(String html) {
    // Simple HTML tag removal for preview
    return html
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  Future<void> _handleGenerate() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Build additional info
      String? additionalInfo = _additionalInfoController.text.trim();

      // If user wants to use existing content, prepend it to additionalInfo
      if (_useExistingContent &&
          widget.existingContent != null &&
          widget.existingContent!.trim().isNotEmpty) {
        final existingText = _stripHtmlTags(widget.existingContent!);
        if (existingText.isNotEmpty) {
          final prefix = 'Dựa trên nội dung mô tả hiện tại:\n\n$existingText';
          additionalInfo = additionalInfo.isEmpty
              ? prefix
              : '$prefix\n\nThông tin bổ sung:\n$additionalInfo';
        }
      }

      final request = GenerateDescriptionRequest(
        title: '', // Will be set by parent
        tone: _selectedTone,
        length: _selectedLength,
        target: _selectedTarget,
        startTime: '', // Will be set by parent
        additionalInfo: additionalInfo.isEmpty ? null : additionalInfo,
      );

      await widget.onGenerate(request);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red500),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fixed)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.vkuBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.vkuBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMD),
                  Expanded(
                    child: Text(
                      'Tạo mô tả với AI',
                      style: AppTextStyles.heading4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _isGenerating
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn cấu hình để AI tạo mô tả phù hợp:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.coolGray700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceLG),
                    // Giọng văn
                    Text(
                      'Giọng văn',
                      style: AppTextStyles.heading5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Wrap(
                      spacing: AppSpacing.spaceXS,
                      runSpacing: AppSpacing.spaceXS,
                      children: ContentTone.values.map((tone) {
                        final isSelected = _selectedTone == tone;
                        return ChoiceChip(
                          label: Text(_getToneLabel(tone)),
                          selected: isSelected,
                          onSelected: _isGenerating
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedTone = tone;
                                    });
                                  }
                                },
                          selectedColor: AppColors.vkuBlue.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.vkuBlue
                                : AppColors.coolGray700,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.vkuBlue
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    // Độ dài
                    Text(
                      'Độ dài',
                      style: AppTextStyles.heading5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Wrap(
                      spacing: AppSpacing.spaceXS,
                      runSpacing: AppSpacing.spaceXS,
                      children: ContentLength.values.map((length) {
                        final isSelected = _selectedLength == length;
                        return ChoiceChip(
                          label: Text(_getLengthLabel(length)),
                          selected: isSelected,
                          onSelected: _isGenerating
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedLength = length;
                                    });
                                  }
                                },
                          selectedColor: AppColors.vkuBlue.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.vkuBlue
                                : AppColors.coolGray700,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.vkuBlue
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    // Nền tảng đích
                    Text(
                      'Nền tảng đích',
                      style: AppTextStyles.heading5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Wrap(
                      spacing: AppSpacing.spaceXS,
                      runSpacing: AppSpacing.spaceXS,
                      children: ContentTarget.values.map((target) {
                        final isSelected = _selectedTarget == target;
                        return ChoiceChip(
                          label: Text(_getTargetLabel(target)),
                          selected: isSelected,
                          onSelected: _isGenerating
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedTarget = target;
                                    });
                                  }
                                },
                          selectedColor: AppColors.vkuBlue.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.vkuBlue
                                : AppColors.coolGray700,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.vkuBlue
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                    ),
                    // Option to use existing content (if available)
                    if (widget.existingContent != null &&
                        widget.existingContent!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.spaceMD),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.spaceMD),
                        decoration: BoxDecoration(
                          color: AppColors.vkuBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.vkuBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _useExistingContent,
                              onChanged: _isGenerating
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _useExistingContent = value ?? false;
                                      });
                                    },
                              activeColor: AppColors.vkuBlue,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dựa trên nội dung hiện tại',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'AI sẽ cải thiện và tạo lại dựa trên mô tả bạn đã có',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.coolGray500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.spaceMD),
                    // Thông tin bổ sung
                    Text(
                      'Thông tin bổ sung (tùy chọn)',
                      style: AppTextStyles.heading5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    TextField(
                      controller: _additionalInfoController,
                      enabled: !_isGenerating,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Nhập thông tin bổ sung để AI tạo mô tả chính xác hơn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.vkuBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.coolGray50,
                        contentPadding: const EdgeInsets.all(
                          AppSpacing.spaceMD,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            // Buttons (fixed at bottom)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isGenerating
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: AppSpacing.spaceXS),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _handleGenerate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(_isGenerating ? 'Đang tạo...' : 'Tạo ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vkuBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceLG,
                        vertical: AppSpacing.spaceMD,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
