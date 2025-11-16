import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  File? _bannerImage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Nếu endDate đã được chọn và nhỏ hơn startDate, reset endDate
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
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
          _bannerImage = File(image.path);
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

  String? _validateDescription(String? value) {
    // Mô tả không bắt buộc nhưng nếu có thì phải hợp lệ
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

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
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

    // TODO: Gọi BLoC để tạo sự kiện
    // Tạm thời hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sự kiện đã được tạo'),
        backgroundColor: AppColors.green500,
      ),
    );

    // Navigate back to event list
    context.pop();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa chọn';
    return DateFormat('dd/MM/yyyy', 'vi').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Chưa chọn';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo sự kiện mới'),
        backgroundColor: AppColors.vkuBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Container(
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
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả sự kiện',
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Nhập mô tả chi tiết về sự kiện',
                          alignLabelWithHint: true,
                        ),
                        validator: _validateDescription,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
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

                      // ===== Thời gian bắt đầu =====
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectStartDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Ngày bắt đầu *',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
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
                            child: InkWell(
                              onTap: _selectStartTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Giờ bắt đầu *',
                                  prefixIcon: Icon(Icons.access_time),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
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

                      // ===== Thời gian kết thúc =====
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectEndDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Ngày kết thúc *',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
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
                            child: InkWell(
                              onTap: _selectEndTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Giờ kết thúc *',
                                  prefixIcon: Icon(Icons.access_time),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
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

                      // ===== Banner =====
                      Text(
                        'Banner sự kiện',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.coolGray700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceXM),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.coolGray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: _bannerImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _bannerImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate,
                                      size: 48,
                                      color: AppColors.coolGray500,
                                    ),
                                    const SizedBox(height: AppSpacing.spaceXM),
                                    Text(
                                      'Tải lên Banner',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.coolGray500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceLG),

                      // ===== Nút Tạo sự kiện =====
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.spaceMD,
                            ),
                          ),
                          child: const Text(
                            'Tạo sự kiện',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }
}
