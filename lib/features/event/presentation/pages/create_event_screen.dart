import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/create_event_dto.dart';
import 'package:event_management/features/event/presentation/bloc/create_event/create_event_bloc.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _maxParticipantsController =
      TextEditingController();
  final TextEditingController _urlDocsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _bannerImage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _urlDocsController.dispose();
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
    if (_startDate == null) {
      return 'Vui lòng chọn ngày bắt đầu';
    }
    if (_endDate == null) {
      return 'Vui lòng chọn ngày kết thúc';
    }

    if (_endDate!.isBefore(_startDate!) ||
        _endDate!.isAtSameMomentAs(_startDate!)) {
      return 'Ngày kết thúc phải sau ngày bắt đầu';
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

    final startDateTime = DateTime.utc(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
    );
    final endDateTime = DateTime.utc(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      23,
      59,
      59,
    );

    final dto = CreateEventDto(
      title: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      startTime: startDateTime.toIso8601String(),
      endTime: endDateTime.toIso8601String(),
      maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 0,
      urlDocs: _urlDocsController.text,
    );

    context.read<CreateEventBloc>().add(
      CreateEventSubmitted(createEventDto: dto, bannerImage: _bannerImage),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa chọn';
    return DateFormat('dd/MM/yyyy', 'vi').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<CreateEventBloc, CreateEventState>(
        listener: (context, state) {
          if (state is CreateEventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sự kiện đã được tạo thành công!'),
                backgroundColor: AppColors.green500,
              ),
            );
            context.pop();
          } else if (state is CreateEventFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.red500,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // ===== Header =====
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vkuBlue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/admin');
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tạo mới',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sự Kiện Mới',
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w900,
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
            ),
            // ===== Form =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coolGray900.withOpacity(0.08),
                          blurRadius: 20,
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

                        // ===== Thời gian bắt đầu và kết thúc =====
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectStartDate,
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
                                        Icons.calendar_today,
                                        color: _startDate == null
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
                                              'Ngày bắt đầu',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.coolGray500,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(_startDate),
                                              style: _startDate == null
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
                                onTap: _selectEndDate,
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
                                        Icons.calendar_today,
                                        color: _endDate == null
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
                                              'Ngày kết thúc',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.coolGray500,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(_endDate),
                                              style: _endDate == null
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
                            child: _bannerImage != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
