import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/admin/presentation/widgets/edit_event/edit_event_date_time_picker.dart';
import 'package:event_management/features/admin/presentation/widgets/edit_event/edit_event_form_fields.dart';
import 'package:event_management/features/admin/presentation/widgets/edit_event/edit_event_header.dart';
import 'package:event_management/features/admin/presentation/widgets/user_search_field.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/edit_event/edit_event_bloc.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_banner_section.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditEventScreen extends StatelessWidget {
  const EditEventScreen({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<EditEventBloc>()
            ..add(EditEventInitialized(eventDetail: eventDetail)),
      child: const _EditEventView(),
    );
  }
}

class _EditEventView extends StatefulWidget {
  const _EditEventView();

  @override
  State<_EditEventView> createState() => _EditEventViewState();
}

class _EditEventViewState extends State<_EditEventView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _urlDocsController;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers - will be updated by BLoC
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _urlDocsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _urlDocsController.dispose();
    super.dispose();
  }

  void _initializeControllers(EditEventFormState state) {
    if (!_controllersInitialized) {
      _titleController.text = state.title;
      _descriptionController.text = state.description;
      _locationController.text = state.location;
      _maxParticipantsController.text = state.maxParticipants.toString();
      _urlDocsController.text = state.urlDocs;
      _controllersInitialized = true;
    }
  }

  Future<void> _selectStartDate(DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      final newDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
      context.read<EditEventBloc>().add(EditEventStartDateChanged(newDate));
    }
  }

  Future<void> _selectStartTime(DateTime currentDate) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
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
      final newDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
      context.read<EditEventBloc>().add(EditEventStartDateChanged(newDate));
    }
  }

  Future<void> _selectEndDate(DateTime currentDate, DateTime startDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      final newDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
      context.read<EditEventBloc>().add(EditEventEndDateChanged(newDate));
    }
  }

  Future<void> _selectEndTime(DateTime currentDate) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
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
      final newDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
      context.read<EditEventBloc>().add(EditEventEndDateChanged(newDate));
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
        final bannerImage = !kIsWeb ? File(pickedFile.path) : null;
        context.read<EditEventBloc>().add(
          EditEventBannerChanged(
            bannerImage: bannerImage,
            bannerImageFile: pickedFile,
          ),
        );
      }
    }
  }

  void _onSave(EditEventFormState state) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Update state with current form values
    context.read<EditEventBloc>()
      ..add(EditEventTitleChanged(_titleController.text))
      ..add(EditEventDescriptionChanged(_descriptionController.text))
      ..add(EditEventLocationChanged(_locationController.text))
      ..add(
        EditEventMaxParticipantsChanged(
          int.tryParse(_maxParticipantsController.text) ?? 0,
        ),
      )
      ..add(EditEventUrlDocsChanged(_urlDocsController.text))
      ..add(EditEventSubmitted(state.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditEventBloc, EditEventState>(
      listenWhen: (previous, current) {
        return current is EditEventSaveSuccess &&
            previous is! EditEventSaveSuccess;
      },
      listener: (context, state) {
        if (state is EditEventSaveSuccess) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cập nhật sự kiện thành công!'),
              backgroundColor: AppColors.green500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          // Delay nhỏ để đảm bảo SnackBar được hiển thị trước khi pop
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              // Quay về trang admin thay vì pop để tránh reload
              context.go(AppRoutes.admin);
            }
          });
        }
      },
      child: BlocListener<EditEventBloc, EditEventState>(
        listenWhen: (previous, current) {
          // Lắng nghe các state lỗi
          return (current is EditEventSaveError &&
                  previous is! EditEventSaveError) ||
              (current is EditEventUsersLoadError &&
                  previous is! EditEventUsersLoadError) ||
              (current is EditEventManagerAssignError &&
                  previous is! EditEventManagerAssignError) ||
              (current is EditEventManagerRemoveError &&
                  previous is! EditEventManagerRemoveError);
        },
        listener: (context, state) {
          if (state is EditEventSaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.error}'),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is EditEventUsersLoadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Không thể tải danh sách người dùng: ${state.error}',
                ),
                backgroundColor: AppColors.red500,
              ),
            );
          } else if (state is EditEventManagerAssignError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không thể gán manager: ${state.error}'),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is EditEventManagerRemoveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không thể xóa manager: ${state.error}'),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<EditEventBloc, EditEventState>(
          builder: (context, state) {
            if (state is EditEventFormState) {
              // Initialize controllers only once when state is first loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeControllers(state);
              });

              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                body: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: EditEventHeader(eventTitle: state.title),
                    ),
                    // Form
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
                                  color: AppColors.coolGray900.withOpacity(
                                    0.08,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Banner
                                const EditEventSectionHeader(
                                  title: 'Ảnh bìa sự kiện',
                                ),
                                EditEventBannerSection(
                                  bannerImage: state.bannerImage is File
                                      ? state.bannerImage as File?
                                      : null,
                                  bannerImageFile: state.bannerImageFile,
                                  bannerUrl: state.bannerUrl,
                                  onPickImage: _pickImage,
                                ),
                                const SizedBox(height: AppSpacing.spaceLG),

                                // Basic Info
                                const EditEventSectionHeader(
                                  title: 'Thông tin cơ bản',
                                ),
                                EditEventFormFields(
                                  titleController: _titleController,
                                  descriptionController: _descriptionController,
                                  locationController: _locationController,
                                  maxParticipantsController:
                                      _maxParticipantsController,
                                  urlDocsController: _urlDocsController,
                                  onTitleChanged: (value) {
                                    context.read<EditEventBloc>().add(
                                      EditEventTitleChanged(value),
                                    );
                                  },
                                  onDescriptionChanged: (value) {
                                    context.read<EditEventBloc>().add(
                                      EditEventDescriptionChanged(value),
                                    );
                                  },
                                  onLocationChanged: (value) {
                                    context.read<EditEventBloc>().add(
                                      EditEventLocationChanged(value),
                                    );
                                  },
                                  onMaxParticipantsChanged: (value) {
                                    final intValue = int.tryParse(value) ?? 0;
                                    context.read<EditEventBloc>().add(
                                      EditEventMaxParticipantsChanged(intValue),
                                    );
                                  },
                                  onUrlDocsChanged: (value) {
                                    context.read<EditEventBloc>().add(
                                      EditEventUrlDocsChanged(value),
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.spaceLG),

                                // Time & Location
                                const EditEventSectionHeader(
                                  title: 'Thời gian & Địa điểm',
                                ),
                                EditEventDateTimePicker(
                                  startDate: state.startDate,
                                  endDate: state.endDate,
                                  onStartDateChanged: () =>
                                      _selectStartDate(state.startDate),
                                  onStartTimeChanged: () =>
                                      _selectStartTime(state.startDate),
                                  onEndDateChanged: () => _selectEndDate(
                                    state.endDate,
                                    state.startDate,
                                  ),
                                  onEndTimeChanged: () =>
                                      _selectEndTime(state.endDate),
                                ),
                                const SizedBox(height: AppSpacing.spaceLG),

                                // Manager Management
                                const EditEventSectionHeader(
                                  title: 'Quản lý người quản lý',
                                ),
                                if (state.allUsers.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        AppSpacing.spaceLG,
                                      ),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else
                                  UserSearchField(
                                    key: ValueKey(
                                      'user_search_${state.selectedManagers.length}_${state.selectedManagers.map((m) => m.userId).join(",")}',
                                    ),
                                    allUsers: state.allUsers,
                                    selectedUsers: state.allUsers
                                        .where(
                                          (u) => state.selectedManagers.any(
                                            (m) => m.userId == u.id,
                                          ),
                                        )
                                        .toList(),
                                    onUserSelected: (user) {
                                      context.read<EditEventBloc>().add(
                                        EditEventManagerAdded(user),
                                      );
                                    },
                                    onUserRemoved: (user) {
                                      context.read<EditEventBloc>().add(
                                        EditEventManagerRemoved(user),
                                      );
                                    },
                                  ),
                                const SizedBox(height: AppSpacing.spaceLG),

                                // Save Button
                                BlocBuilder<EditEventBloc, EditEventState>(
                                  builder: (context, saveState) {
                                    final isLoading =
                                        saveState is EditEventSaving;
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: isLoading
                                            ? null
                                            : () => _onSave(state),
                                        icon: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.white),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.save_rounded,
                                                size: 24,
                                              ),
                                        label: Text(
                                          isLoading
                                              ? 'Đang lưu...'
                                              : 'Lưu thay đổi',
                                          style: AppTextStyles.heading5
                                              .copyWith(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.vkuBlue,
                                          foregroundColor: AppColors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 2,
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
              );
            }

            // Loading state
            return const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
