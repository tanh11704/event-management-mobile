import 'package:event_management/core/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditEventImagePicker {
  EditEventImagePicker._();

  static Future<ImageSource?> showImageSourcePicker(
    BuildContext context,
  ) async {
    try {
      FocusScope.of(context).unfocus();

      await Future<void>.delayed(const Duration(milliseconds: 150));

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
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.vkuBlue,
                  ),
                  title: const Text('Chụp ảnh'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      return source;
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().contains('JavaScript')
            ? 'Không thể chọn ảnh. Vui lòng thử lại sau vài giây.'
            : 'Không thể chọn ảnh. Vui lòng thử lại.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  /// Pick image từ source đã chọn
  /// Trả về XFile? để tương thích với cả web và mobile
  static Future<XFile?> pickImage({
    required BuildContext context,
    required ImagePicker imagePicker,
    required ImageSource source,
  }) async {
    try {
      // Add a small delay to avoid conflicts with WebView/JavaScript
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null && context.mounted) {
        return pickedFile;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().contains('JavaScript')
            ? 'Không thể chọn ảnh. Vui lòng thử lại sau vài giây.'
            : 'Không thể chọn ảnh. Vui lòng thử lại.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }
}
