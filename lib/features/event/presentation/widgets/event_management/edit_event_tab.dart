import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_banner_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_html_editor.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_modern_text_field.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_picker_field.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditEventTab extends StatefulWidget {
  const EditEventTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  State<EditEventTab> createState() => _EditEventTabState();
}

class _EditEventTabState extends State<EditEventTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _htmlEditorKey = GlobalKey();
  late TextEditingController _titleController;
  String _descriptionHtml = '';
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _urlDocsController;

  late DateTime _startDate;
  late DateTime _endDate;
  File? _bannerImage;
  String? _bannerUrl;

  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'vi');
  final DateFormat _timeFormat = DateFormat('HH:mm', 'vi');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventDetail.title);
    _descriptionHtml = widget.eventDetail.description ?? '';
    _locationController = TextEditingController(
      text: widget.eventDetail.location ?? '',
    );
    _maxParticipantsController = TextEditingController(
      text: widget.eventDetail.maxParticipants?.toString() ?? '',
    );
    _urlDocsController = TextEditingController(
      text: widget.eventDetail.urlDocs ?? '',
    );
    _startDate = widget.eventDetail.startTime;
    _endDate = widget.eventDetail.endTime;
    _bannerUrl = widget.eventDetail.banner;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _urlDocsController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startDate.hour,
          _startDate.minute,
        );
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.vkuBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endDate.hour,
          _endDate.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.vkuBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(
          _endDate.year,
          _endDate.month,
          _endDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.vkuBlue,
                ),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.vkuBlue),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _bannerImage = File(pickedFile.path);
          _bannerUrl = null;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    final htmlEditorState = _htmlEditorKey.currentState;
    if (htmlEditorState != null) {
      final dynamic state = htmlEditorState;
      if (state.validate != null) {
        final error = await state.validate() as String?;
        if (error != null) {
          return;
        }
        _descriptionHtml = await state.getText() as String;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement API call to update event
    await Future<void>.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật thông tin sự kiện thành công!'),
          backgroundColor: AppColors.green500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceMD,
        AppSpacing.spaceMD,
        AppSpacing.spaceMD,
        AppSpacing.spaceMD + 40,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EditEventSectionHeader(title: 'Ảnh bìa sự kiện'),
            EditEventBannerSection(
              bannerImage: _bannerImage,
              bannerUrl: _bannerUrl,
              onPickImage: _pickImage,
            ),

            const EditEventSectionHeader(title: 'Thông tin cơ bản'),
            EditEventModernTextField(
              controller: _titleController,
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
            const EditEventSectionHeader(title: 'Mô tả'),
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
                  return 'Vui lòng nhập mô tả';
                }
                return null;
              },
            ),

            const EditEventSectionHeader(title: 'Thời gian & Địa điểm'),
            Row(
              children: [
                Expanded(
                  child: EditEventPickerField(
                    label: 'Ngày bắt đầu',
                    text: _dateFormat.format(_startDate),
                    icon: Icons.calendar_today_rounded,
                    onTap: _selectStartDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceMD),
                Expanded(
                  child: EditEventPickerField(
                    label: 'Giờ bắt đầu',
                    text: _timeFormat.format(_startDate),
                    icon: Icons.access_time_rounded,
                    onTap: _selectStartTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            Row(
              children: [
                Expanded(
                  child: EditEventPickerField(
                    label: 'Ngày kết thúc',
                    text: _dateFormat.format(_endDate),
                    icon: Icons.calendar_today_rounded,
                    onTap: _selectEndDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceMD),
                Expanded(
                  child: EditEventPickerField(
                    label: 'Giờ kết thúc',
                    text: _timeFormat.format(_endDate),
                    icon: Icons.access_time_rounded,
                    onTap: _selectEndTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            EditEventModernTextField(
              controller: _locationController,
              label: 'Địa điểm',
              icon: Icons.location_on_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa điểm';
                }
                return null;
              },
            ),

            const EditEventSectionHeader(title: 'Tùy chọn bổ sung'),
            EditEventModernTextField(
              controller: _maxParticipantsController,
              label: 'Số lượng tối đa',
              icon: Icons.people_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số lượng';
                }
                final num = int.tryParse(value);
                if (num == null || num <= 0) {
                  return 'Số lượng phải lớn hơn 0';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            EditEventModernTextField(
              controller: _urlDocsController,
              label: 'Link tài liệu (tùy chọn)',
              icon: Icons.link_rounded,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.spaceLG * 2),

            // Nút Save (giữ nguyên, đã tốt)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon: _isLoading
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
                    : const Icon(Icons.save_rounded, size: 24),
                label: Text(
                  _isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
                  style: AppTextStyles.heading5.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vkuBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
