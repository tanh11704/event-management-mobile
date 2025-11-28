import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/event/event_create/presentation/bloc/create_event_bloc.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/ai_description_generator_dialog.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_html_editor.dart';
import 'package:event_management/features/event/shared/data/models/create_event_dto.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_request.dart';
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CreateEventView();
  }
}

class _CreateEventView extends StatefulWidget {
  const _CreateEventView();

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _htmlEditorKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _maxParticipantsController =
      TextEditingController();
  final TextEditingController _urlDocsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _startTime;
  DateTime? _endDate;
  DateTime? _endTime;
  String _descriptionHtml = '';
  File? _bannerImage;
  XFile? _bannerImageFile;

  final ImagePicker _imagePicker = ImagePicker();
  bool _isGeneratingDescription = false;

  Future<void> _handleAiGenerate(GenerateDescriptionRequest request) async {
    if (_nameController.text.trim().isEmpty) {
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

    if (_startDate == null || _startTime == null) {
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
      _isGeneratingDescription = true;
    });

    try {
      final repository = di.sl<EventRepository>();
      // Create local DateTime first, then convert to UTC
      final startDateTimeLocal = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTimeLocal = _endDate != null && _endTime != null
          ? DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              _endTime!.hour,
              _endTime!.minute,
            )
          : null;
      // Convert local time to UTC
      final startDateTime = startDateTimeLocal.toUtc();
      final endDateTime = endDateTimeLocal?.toUtc();

      final fullRequest = GenerateDescriptionRequest(
        title: _nameController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        startTime: startDateTime.toIso8601String(),
        endTime: endDateTime?.toIso8601String(),
        additionalInfo: request.additionalInfo,
        tone: request.tone,
        length: request.length,
        target: request.target,
      );

      final response = await repository.generateDescription(fullRequest);

      if (mounted) {
        // Set the generated description to the HTML editor
        final editorState = _htmlEditorKey.currentState;
        if (editorState != null) {
          final dynamic state = editorState;
          await state.setText(response.description);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo mô tả thành công!'),
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
          _isGeneratingDescription = false;
        });
      }
    }
  }

  void _showAiDialog() {
    showDialog<void>(
      context: context,
      builder: (context) =>
          AiDescriptionGeneratorDialog(onGenerate: _handleAiGenerate),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _urlDocsController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDateTime() async {
    // Select date first
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null) {
      // Then select time
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _startTime != null
            ? TimeOfDay.fromDateTime(_startTime!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          _startDate = pickedDate;
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // Reset end date/time if invalid
          if (_endDate != null && _endTime != null) {
            final endDateTime = DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              _endTime!.hour,
              _endTime!.minute,
            );
            if (endDateTime.isBefore(_startTime!) ||
                endDateTime.isAtSameMomentAs(_startTime!)) {
              _endDate = null;
              _endTime = null;
            }
          }
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thời gian bắt đầu trước'),
          backgroundColor: AppColors.red500,
        ),
      );
      return;
    }

    // Select date first
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null) {
      // Then select time
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime != null
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.fromDateTime(_startTime!),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        final endDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (endDateTime.isBefore(_startTime!) ||
            endDateTime.isAtSameMomentAs(_startTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thời gian kết thúc phải sau thời gian bắt đầu'),
              backgroundColor: AppColors.red500,
            ),
          );
          return;
        }
        setState(() {
          _endDate = pickedDate;
          _endTime = endDateTime;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _bannerImageFile = image;
          if (!kIsWeb) {
            _bannerImage = File(image.path);
          }
        });
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên sự kiện';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    // Địa điểm không bắt buộc nhưng nếu có thì phải hợp lệ
    return null;
  }

  String? _validateDateTime() {
    if (_startDate == null || _startTime == null) {
      return 'Vui lòng chọn thời gian bắt đầu';
    }
    if (_endDate == null || _endTime == null) {
      return 'Vui lòng chọn thời gian kết thúc';
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      return 'Thời gian kết thúc phải sau thời gian bắt đầu';
    }

    return null;
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate HTML editor
    final editorState = _htmlEditorKey.currentState;
    if (editorState != null) {
      final dynamic state = editorState;
      final error = await state.validate();
      if (error != null) {
        return;
      }
      // Get HTML content from editor
      _descriptionHtml = await state.getText() as String;
    }

    final dateTimeError = _validateDateTime();
    if (dateTimeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateTimeError),
          backgroundColor: AppColors.red500,
        ),
      );
      return;
    }

    // Create local DateTime first, then convert to UTC
    final startDateTimeLocal = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTimeLocal = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    // Convert local time to UTC
    final startDateTime = startDateTimeLocal.toUtc();
    final endDateTime = endDateTimeLocal.toUtc();

    final dto = CreateEventDto(
      title: _nameController.text,
      description: _descriptionHtml,
      location: _locationController.text,
      startTime: startDateTime.toIso8601String(),
      endTime: endDateTime.toIso8601String(),
      maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 0,
      urlDocs: _urlDocsController.text,
    );

    context.read<CreateEventBloc>().add(
      CreateEventSubmitted(
        createEventDto: dto,
        bannerImageFile: _bannerImageFile,
      ),
    );
  }

  String _formatDateTime(DateTime? date, DateTime? time) {
    if (date == null || time == null) return 'Chưa chọn';
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat('dd/MM/yyyy HH:mm', 'vi').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.admin);
            }
          },
        ),
        title: const Text('Tạo sự kiện mới'),
        backgroundColor: AppColors.vkuBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocListener<CreateEventBloc, CreateEventState>(
        listener: (context, state) {
          if (state is CreateEventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sự kiện đã được tạo thành công!'),
                backgroundColor: AppColors.green500,
              ),
            );
            context.go(AppRoutes.admin);
          } else if (state is CreateEventFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.red500,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.background),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Form Container =====
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceLG),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coolGray500.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== Tên sự kiện =====
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên sự kiện *',
                            prefixIcon: Icon(Icons.event),
                            hintText: 'Nhập tên sự kiện',
                          ),
                          validator: _validateName,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== Mô tả sự kiện =====
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Mô tả sự kiện',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.coolGray700,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isGeneratingDescription
                                  ? null
                                  : _showAiDialog,
                              icon: _isGeneratingDescription
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.vkuBlue,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                _isGeneratingDescription
                                    ? 'Đang tạo...'
                                    : 'Tạo với AI',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.vkuBlue,
                                side: const BorderSide(
                                  color: AppColors.vkuBlue,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.spaceMD,
                                  vertical: AppSpacing.spaceXS,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceXS),
                        EditEventHtmlEditor(
                          key: _htmlEditorKey,
                          initialValue: _descriptionHtml,
                          onChanged: (value) {
                            setState(() {
                              _descriptionHtml = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập mô tả sự kiện';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== Địa điểm =====
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Địa điểm',
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'Nhập địa điểm tổ chức',
                          ),
                          validator: _validateLocation,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== Thời gian bắt đầu và kết thúc =====
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectStartDateTime,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color:
                                            (_startDate == null ||
                                                _startTime == null)
                                            ? AppColors.coolGray500
                                            : AppColors.vkuBlue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Thời gian bắt đầu',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.coolGray500,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDateTime(
                                                _startDate,
                                                _startTime,
                                              ),
                                              style:
                                                  (_startDate == null ||
                                                      _startTime == null)
                                                  ? AppTextStyles.bodyMedium
                                                        .copyWith(
                                                          color: AppColors
                                                              .coolGray500,
                                                        )
                                                  : AppTextStyles.bodyMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spaceMD),
                            Expanded(
                              child: InkWell(
                                onTap: _selectEndDateTime,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color:
                                            (_endDate == null ||
                                                _endTime == null)
                                            ? AppColors.coolGray500
                                            : AppColors.vkuBlue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Thời gian kết thúc',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.coolGray500,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDateTime(
                                                _endDate,
                                                _endTime,
                                              ),
                                              style:
                                                  (_endDate == null ||
                                                      _endTime == null)
                                                  ? AppTextStyles.bodyMedium
                                                        .copyWith(
                                                          color: AppColors
                                                              .coolGray500,
                                                        )
                                                  : AppTextStyles.bodyMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== Số người tham gia tối đa =====
                        TextFormField(
                          controller: _maxParticipantsController,
                          decoration: const InputDecoration(
                            labelText: 'Số người tham gia tối đa',
                            prefixIcon: Icon(Icons.people),
                            hintText: 'Nhập số lượng (nếu có)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== Link tài liệu =====
                        TextFormField(
                          controller: _urlDocsController,
                          decoration: const InputDecoration(
                            labelText: 'Link tài liệu',
                            prefixIcon: Icon(Icons.link),
                            hintText: 'Nhập URL tài liệu liên quan (nếu có)',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== Banner =====
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: _bannerImage == null
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.vkuBlue.withOpacity(0.05),
                                        AppColors.coolGray50,
                                      ],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _bannerImage == null
                                    ? AppColors.border
                                    : AppColors.vkuBlue.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _bannerImageFile != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: kIsWeb
                                            ? Image.network(
                                                _bannerImageFile!.path,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : Image.file(
                                                _bannerImage!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.vkuBlue.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 48,
                                          color: AppColors.vkuBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tải lên ảnh Banner',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.coolGray700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nhấn để chọn ảnh từ thư viện',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.coolGray500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceLG),

                        // ===== Nút Tạo sự kiện =====
                        BlocBuilder<CreateEventBloc, CreateEventState>(
                          builder: (context, state) {
                            final isLoading = state is CreateEventLoading;
                            return Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: isLoading
                                    ? null
                                    : AppColors.primaryGradient,
                                color: isLoading ? AppColors.coolGray500 : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isLoading
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: AppColors.vkuBlue.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_circle_outline,
                                            color: AppColors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Tạo sự kiện',
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
