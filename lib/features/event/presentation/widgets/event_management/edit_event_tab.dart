import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_banner_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_basic_info_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_date_time_handler.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_date_time_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_form_controller.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_image_picker.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_location_section.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditEventTab extends StatefulWidget {
  const EditEventTab({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  State<EditEventTab> createState() => _EditEventTabState();
}

class _EditEventTabState extends State<EditEventTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _htmlEditorKey = GlobalKey();

  File? _bannerImage;
  XFile? _bannerImageFile;
  String? _bannerUrl;

  late EditEventFormController _formController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formController = EditEventFormController(
      eventDetail: widget.eventDetail,
      eventRepository: sl<EventRepository>(),
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await EditEventDateTimeHandler.selectStartDate(
      context: context,
      initialDate: _formController.startDate,
    );
    if (picked != null) {
      setState(() {
        _formController.startDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _formController.startDate.hour,
          _formController.startDate.minute,
        );
        if (_formController.endDate.isBefore(_formController.startDate)) {
          _formController.endDate = _formController.startDate.add(
            const Duration(hours: 1),
          );
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await EditEventDateTimeHandler.selectStartTime(
      context: context,
      initialDate: _formController.startDate,
    );
    if (picked != null) {
      setState(() {
        _formController.startDate = DateTime(
          _formController.startDate.year,
          _formController.startDate.month,
          _formController.startDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await EditEventDateTimeHandler.selectEndDate(
      context: context,
      initialDate: _formController.endDate,
      startDate: _formController.startDate,
    );
    if (picked != null) {
      setState(() {
        _formController.endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _formController.endDate.hour,
          _formController.endDate.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await EditEventDateTimeHandler.selectEndTime(
      context: context,
      initialDate: _formController.endDate,
    );
    if (picked != null) {
      setState(() {
        _formController.endDate = DateTime(
          _formController.endDate.year,
          _formController.endDate.month,
          _formController.endDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final source = await EditEventImagePicker.showImageSourcePicker(context);
    if (source != null) {
      final pickedFile = await EditEventImagePicker.pickImage(
        context: context,
        imagePicker: _formController.imagePicker,
        source: source,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _bannerImageFile = pickedFile as XFile?;
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
        _formController.descriptionHtml = await state.getText() as String;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Bắt đầu loading state ngay khi bắt đầu xử lý
    setState(() {
      _isLoading = true;
    });

    try {
      final eventDto = await _formController.createEventDto(
        descriptionHtml: _formController.descriptionHtml,
      );

      final bannerXFile = _formController.getBannerXFile();

      context.read<EventDetailBloc>().add(
        EventDetailUpdate(
          eventId: widget.eventDetail.id,
          eventDto: eventDto,
          bannerFile: bannerXFile,
        ),
      );
    } catch (e) {
      // Dừng loading nếu có lỗi
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xử lý ảnh: $e'),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventDetailBloc, EventDetailState>(
      listener: (context, state) {
        if (state is EventDetailSuccess) {
          // Xử lý trạng thái loading
          if (state.isUpdating) {
            setState(() {
              _isLoading = true;
            });
          }
          // Xử lý khi cập nhật thành công
          else if (!state.isUpdating && _isLoading) {
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

            // Chỉ cập nhật bannerUrl TẠI ĐÂY, khi BLoC
            // thực sự vừa cập nhật xong.
            if (_formController.bannerUrl != state.eventDetail.banner) {
              setState(() {
                _formController.bannerUrl = state.eventDetail.banner;
                _formController.bannerImage =
                    null; // Xóa file local sau khi đã lưu
              });
            }
          }
        }
        // Xử lý lỗi
        else if (state is EventDetailError) {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      },
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
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
              bannerImageFile: _bannerImageFile,
              bannerUrl: _bannerUrl,
              onPickImage: _pickImage,
            ),

            EditEventBasicInfoSection(
              titleController: _formController.titleController,
              descriptionHtml: _formController.descriptionHtml,
              htmlEditorKey: _htmlEditorKey,
              onDescriptionChanged: (value) {
                setState(() {
                  _formController.descriptionHtml = value;
                });
              },
            ),

            EditEventDateTimeSection(
              startDate: _formController.startDate,
              endDate: _formController.endDate,
              onStartDateSelected: _selectStartDate,
              onStartTimeSelected: _selectStartTime,
              onEndDateSelected: _selectEndDate,
              onEndTimeSelected: _selectEndTime,
            ),

            EditEventLocationSection(
              locationController: _formController.locationController,
              maxParticipantsController:
                  _formController.maxParticipantsController,
              urlDocsController: _formController.urlDocsController,
            ),

            const SizedBox(height: AppSpacing.spaceLG * 2),

            // Nút Save
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
