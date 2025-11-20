import 'dart:io';

import 'package:event_management/core/utils/html_image_processor.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/event_dto.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Controller để quản lý state và logic của EditEventForm
class EditEventFormController {
  EditEventFormController({
    required EventDetailResponse eventDetail,
    required EventRepository eventRepository,
  }) : _eventDetail = eventDetail,
       _eventRepository = eventRepository {
    _initializeControllers();
  }

  final EventDetailResponse _eventDetail;
  final EventRepository _eventRepository;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  late final TextEditingController titleController;
  late final TextEditingController locationController;
  late final TextEditingController maxParticipantsController;
  late final TextEditingController urlDocsController;

  // State
  String descriptionHtml = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  File? bannerImage;
  String? bannerUrl;

  // Getters
  EventDetailResponse get eventDetail => _eventDetail;
  EventRepository get eventRepository => _eventRepository;
  ImagePicker get imagePicker => _imagePicker;

  void _initializeControllers() {
    titleController = TextEditingController(text: _eventDetail.title);
    descriptionHtml = HtmlImageProcessor.convertImagePathsToUrls(
      _eventDetail.description ?? '',
    );
    locationController = TextEditingController(
      text: _eventDetail.location ?? '',
    );
    maxParticipantsController = TextEditingController(
      text: _eventDetail.maxParticipants?.toString() ?? '',
    );
    urlDocsController = TextEditingController(text: _eventDetail.urlDocs ?? '');
    startDate = _eventDetail.startTime;
    endDate = _eventDetail.endTime;
    bannerUrl = _eventDetail.banner;
  }

  void dispose() {
    titleController.dispose();
    locationController.dispose();
    maxParticipantsController.dispose();
    urlDocsController.dispose();
  }

  /// Tạo EventDto từ form data
  Future<EventDto> createEventDto({required String descriptionHtml}) async {
    // Convert full URL về path trước khi xử lý
    final descriptionToProcess = HtmlImageProcessor.convertImageUrlsToPaths(
      descriptionHtml,
    );

    // Xử lý ảnh base64 trong mô tả: upload lên server và thay thế bằng path
    final processedDescription =
        await HtmlImageProcessor.processBase64ImagesInHtml(
          descriptionToProcess,
          _eventRepository,
        );

    final startDateTimeUtc = startDate.toUtc();
    final endDateTimeUtc = endDate.toUtc();

    return EventDto(
      title: titleController.text.trim(),
      description: processedDescription.trim(),
      startTime: startDateTimeUtc.toIso8601String(),
      endTime: endDateTimeUtc.toIso8601String(),
      location: locationController.text.trim(),
      maxParticipants: int.tryParse(maxParticipantsController.text) ?? 0,
      urlDocs: urlDocsController.text.trim().isEmpty
          ? null
          : urlDocsController.text.trim(),
    );
  }

  /// Lấy banner XFile nếu có
  XFile? getBannerXFile() {
    if (bannerImage != null) {
      return XFile(bannerImage!.path);
    }
    return null;
  }
}
