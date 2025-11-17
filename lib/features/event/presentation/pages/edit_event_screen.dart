import 'dart:typed_data';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_strings.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/presentation/bloc/edit_event_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/edit_event_event.dart';
import 'package:event_management/features/event/presentation/bloc/edit_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({required this.event, super.key});
  final Event event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  XFile? _newBannerImage;
  String? _currentBannerUrl;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.event.title;
    _descriptionController.text = widget.event.description ?? '';
    _locationController.text = widget.event.location ?? '';

    final start = widget.event.startTime;
    final end = widget.event.endTime;

    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _currentBannerUrl = widget.event.banner;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ========== CẬP NHẬT: THÊM LẠI LOGIC CHỌN NGÀY/GIỜ ==========
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  // ========== LOGIC CHỌN ẢNH ==========
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.selectFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(AppStrings.takePicture),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _newBannerImage = image;
        }); // Gán XFile
      }
    }
  }

  // ========== FORMAT & VALIDATE  ==========
  String _formatDate(DateTime? date) {
    if (date == null) return AppStrings.notSelected;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return AppStrings.notSelected;
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  String? _validateDateTime() {
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      return AppStrings.validationError;
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
      return AppStrings.endTimeAfterStartTimeError;
    }
    return null;
  }

  // ========== SUBMIT (KẾT NỐI BLOC) ==========
  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.validationError),
          backgroundColor: AppColors.red500,
        ),
      );
      return;
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

    //  Gửi Event tới BLoC
    context.read<EditEventBloc>().add(
      EditEventSubmitted(
        eventId: widget.event.id,
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        startDate: startDateTime,
        endDate: endDateTime,
        newBannerImage: _newBannerImage,
      ),
    );
  }

  // ========== UI  ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editEventTitle),
        backgroundColor: AppColors.vkuBlue,
        foregroundColor: AppColors.white,
      ),
      // [BLoC] Lắng nghe State
      body: BlocListener<EditEventBloc, EditEventState>(
        listener: (context, state) {
          if (state is EditEventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.saveSuccess),
                backgroundColor: AppColors.green500,
              ),
            );
            context.pop();
          } else if (state is EditEventFailure) {
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
                children: [
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
                        // ===== TÊN SỰ KIỆN =====
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.eventNameLabel, // ✅ [Rule 10]
                            prefixIcon: Icon(Icons.event),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? AppStrings
                                    .pleaseEnterEventName // ✅ [Rule 10]
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== MÔ TẢ =====
                        TextFormField(
                          // ✅ Sửa: Dùng _descriptionController
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText:
                                AppStrings.descriptionLabel, // ✅ [Rule 10]
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== ĐỊA ĐIỂM =====
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.locationLabel, // ✅ [Rule 10]
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== THỜI GIAN BẮT ĐẦU =====
                        Row(
                          children: [
                            Expanded(
                              // ✅ CẬP NHẬT: Thêm InkWell
                              child: InkWell(
                                onTap: _selectStartDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: AppStrings
                                        .startDateLabel, // ✅ [Rule 10]
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _formatDate(_startDate),
                                    style: _startDate == null
                                        ? AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.coolGray500,
                                          )
                                        : AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spaceMD),
                            Expanded(
                              // ✅ CẬP NHẬT: Thêm InkWell
                              child: InkWell(
                                onTap: _selectStartTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: AppStrings
                                        .startTimeLabel, // ✅ [Rule 10]
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(
                                    _formatTime(_startTime),
                                    style: _startTime == null
                                        ? AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.coolGray500,
                                          )
                                        : AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== THỜI GIAN KẾT THÚC =====
                        Row(
                          children: [
                            Expanded(
                              // ✅ CẬP NHẬT: Thêm InkWell
                              child: InkWell(
                                onTap: _selectEndDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText:
                                        AppStrings.endDateLabel, // ✅ [Rule 10]
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _formatDate(_endDate),
                                    style: _endDate == null
                                        ? AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.coolGray500,
                                          )
                                        : AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spaceMD),
                            Expanded(
                              //CẬP NHẬT: Thêm InkWell
                              child: InkWell(
                                onTap: _selectEndTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText:
                                        AppStrings.endTimeLabel, // ✅ [Rule 10]
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(
                                    _formatTime(_endTime),
                                    style: _endTime == null
                                        ? AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.coolGray500,
                                          )
                                        : AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),

                        // ===== BANNER =====
                        Text(
                          AppStrings.eventBanner,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.coolGray700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.coolGray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: _buildBannerImage(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceLG),

                        // ===== NÚT LƯU (KẾT NỐI BLOC) =====
                        BlocBuilder<EditEventBloc, EditEventState>(
                          builder: (context, state) {
                            final isLoading = state is EditEventLoading;

                            return Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                //Dùng _onSubmit
                                onPressed: isLoading ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.spaceMD,
                                  ),
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
                                    : const Text(
                                        AppStrings.saveChanges, // ✅ [Rule 10]
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
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

  // ========== HELPER WIDGET CHO BANNER (Sửa lỗi Rule 10, dùng XFile) ==========

  Widget _buildBannerPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image_search, size: 48, color: AppColors.coolGray500),
        const SizedBox(height: AppSpacing.spaceXM),
        Text(
          AppStrings.uploadNewBanner,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.coolGray500,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerImage() {
    if (_newBannerImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        //Dùng FutureBuilder và Image.memory để hỗ trợ cả web/mobile
        child: FutureBuilder<Uint8List>(
          future: _newBannerImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              );
            }
            if (snapshot.hasError) {
              return _buildBannerPlaceholder();
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }
    // 2. Hiển thị ảnh cũ (Network)
    if (_currentBannerUrl != null && _currentBannerUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _currentBannerUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildBannerPlaceholder();
          },
        ),
      );
    }
    // 3. Không có ảnh, hiển thị placeholder
    return _buildBannerPlaceholder();
  }
}
