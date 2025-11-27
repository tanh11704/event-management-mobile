import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_date_time_handler.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:event_management/features/poll/presentation/bloc/create_poll/create_poll_bloc.dart';
import 'package:event_management/features/poll/presentation/bloc/create_poll/create_poll_event.dart';
import 'package:event_management/features/poll/presentation/bloc/create_poll/create_poll_state.dart';
import 'package:event_management/features/poll/presentation/widgets/create_poll/create_poll_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Section hiển thị form tạo poll mới trong Tools Settings Tab
class CreatePollSection extends StatefulWidget {
  const CreatePollSection({required this.eventId, super.key});

  final int eventId;

  @override
  State<CreatePollSection> createState() => _CreatePollSectionState();
}

class _CreatePollSectionState extends State<CreatePollSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  PollType _selectedPollType = PollType.singleChoice;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    // Thêm 2 options mặc định
    _optionControllers
      ..add(TextEditingController())
      ..add(TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPollTypeChanged(PollType type) {
    setState(() {
      _selectedPollType = type;
    });
  }

  void _onAddOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _onRemoveOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await EditEventDateTimeHandler.selectStartDate(
      context: context,
      initialDate: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await EditEventDateTimeHandler.selectStartTime(
      context: context,
      initialDate: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await EditEventDateTimeHandler.selectEndDate(
      context: context,
      initialDate: _endTime,
      startDate: _startTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await EditEventDateTimeHandler.selectEndTime(
      context: context,
      initialDate: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (options.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất 2 lựa chọn'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
      return;
    }

    if (_endTime.isBefore(_startTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thời gian kết thúc phải sau thời gian bắt đầu'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
      return;
    }

    context.read<CreatePollBloc>().add(
      CreatePollSubmitted(
        title: title,
        pollType: _selectedPollType,
        options: options,
        eventId: widget.eventId,
        startTime: _startTime,
        endTime: _endTime,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    for (final controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _selectedPollType = PollType.singleChoice;
      _startTime = DateTime.now();
      _endTime = DateTime.now().add(const Duration(days: 1));
      // Giữ lại 2 options
      while (_optionControllers.length > 2) {
        _optionControllers.removeLast().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CreatePollBloc>(),
      child: BlocListener<CreatePollBloc, CreatePollState>(
        listener: (context, state) {
          if (state is CreatePollSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo poll thành công!'),
                backgroundColor: AppColors.green500,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _resetForm();
          } else if (state is CreatePollFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.coolGray900.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.amber100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.poll_rounded,
                      color: AppColors.amber600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo Poll mới',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tạo cuộc thăm dò ý kiến và liên kết với sự kiện',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.coolGray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              const Divider(),
              const SizedBox(height: AppSpacing.spaceLG),

              // Form
              CreatePollForm(
                formKey: _formKey,
                titleController: _titleController,
                selectedPollType: _selectedPollType,
                optionControllers: _optionControllers,
                onPollTypeChanged: _onPollTypeChanged,
                onAddOption: _onAddOption,
                onRemoveOption: _onRemoveOption,
                startTime: _startTime,
                endTime: _endTime,
                onStartDateSelected: _selectStartDate,
                onStartTimeSelected: _selectStartTime,
                onEndDateSelected: _selectEndDate,
                onEndTimeSelected: _selectEndTime,
              ),
              const SizedBox(height: AppSpacing.spaceXL),

              // Submit Button
              BlocBuilder<CreatePollBloc, CreatePollState>(
                builder: (context, state) {
                  final isLoading = state is CreatePollLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vkuBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spaceMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.spaceXM),
                                Text(
                                  'Lưu và bắt đầu Poll',
                                  style: AppTextStyles.heading5.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
