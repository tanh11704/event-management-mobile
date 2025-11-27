import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:event_management/features/poll/presentation/widgets/poll_components/poll_date_time_section.dart';
import 'package:event_management/features/poll/presentation/widgets/poll_components/poll_option_input.dart';
import 'package:event_management/features/poll/presentation/widgets/poll_components/poll_type_selector.dart';
import 'package:flutter/material.dart';

/// Form widget để tạo poll mới
class CreatePollForm extends StatefulWidget {
  const CreatePollForm({
    required this.titleController,
    required this.selectedPollType,
    required this.optionControllers,
    required this.onPollTypeChanged,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.formKey,
    required this.startTime,
    required this.endTime,
    required this.onStartDateSelected,
    required this.onStartTimeSelected,
    required this.onEndDateSelected,
    required this.onEndTimeSelected,
    super.key,
  });

  final TextEditingController titleController;
  final PollType selectedPollType;
  final List<TextEditingController> optionControllers;
  final ValueChanged<PollType> onPollTypeChanged;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;
  final GlobalKey<FormState> formKey;
  final DateTime startTime;
  final DateTime endTime;
  final VoidCallback onStartDateSelected;
  final VoidCallback onStartTimeSelected;
  final VoidCallback onEndDateSelected;
  final VoidCallback onEndTimeSelected;

  @override
  State<CreatePollForm> createState() => _CreatePollFormState();
}

class _CreatePollFormState extends State<CreatePollForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const EditEventSectionHeader(title: 'Tiêu đề'),
          const SizedBox(height: AppSpacing.spaceXM),
          _TitleTextField(
            controller: widget.titleController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tiêu đề';
              }
              if (value.trim().length < 5) {
                return 'Tiêu đề phải có ít nhất 5 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.spaceLG),

          // Thời gian
          PollDateTimeSection(
            startTime: widget.startTime,
            endTime: widget.endTime,
            onStartDateSelected: widget.onStartDateSelected,
            onStartTimeSelected: widget.onStartTimeSelected,
            onEndDateSelected: widget.onEndDateSelected,
            onEndTimeSelected: widget.onEndTimeSelected,
          ),
          const SizedBox(height: AppSpacing.spaceLG),

          // Loại poll
          const EditEventSectionHeader(title: 'Loại poll'),
          const SizedBox(height: AppSpacing.spaceXM),
          PollTypeSelector(
            selectedType: widget.selectedPollType,
            onTypeChanged: widget.onPollTypeChanged,
          ),
          const SizedBox(height: AppSpacing.spaceLG),

          // Các lựa chọn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EditEventSectionHeader(title: 'Các lựa chọn'),
              TextButton.icon(
                onPressed: widget.onAddOption,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.vkuBlue,
                  size: 20,
                ),
                label: Text(
                  'Thêm lựa chọn',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.vkuBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXM),
          ...widget.optionControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            final isDeletable = widget.optionControllers.length > 2;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < widget.optionControllers.length - 1
                    ? AppSpacing.spaceMD
                    : 0,
              ),
              child: PollOptionInput(
                controller: controller,
                index: index,
                isDeletable: isDeletable,
                onDelete: () => widget.onRemoveOption(index),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lựa chọn';
                  }
                  if (value.trim().length < 2) {
                    return 'Lựa chọn phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Custom title text field với text alignment: căn trái ngang, căn giữa dọc
class _TitleTextField extends StatelessWidget {
  const _TitleTextField({
    required this.controller,
    this.validator,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.coolGray900,
      ),
      decoration: InputDecoration(
        labelText: 'Nhập tiêu đề cho poll',
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.coolGray700,
        ),
        hintText: 'Nhập tiêu đề cho poll',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.coolGray500,
        ),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: const Icon(
          Icons.title_rounded,
          color: AppColors.vkuBlue,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.vkuBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red500, width: 1.5),
        ),
      ),
    );
  }
}
