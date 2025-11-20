import 'dart:convert';
import 'dart:io';

import 'package:event_management/core/services/cloudinary_image_service.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class để xử lý ảnh trong HTML content
///
/// Tuân theo các nguyên tắc:
/// - DRY: Tái sử dụng code cho create và edit event
/// - KISS: Đơn giản, dễ hiểu
/// - SOLID: Single Responsibility - chỉ xử lý HTML images
class HtmlImageProcessor {
  HtmlImageProcessor._();

  /// Regex patterns để tìm thẻ img trong HTML
  static final _imgRegexDouble = RegExp(
    r'<img([^>]*)\s+src="([^"]+)"([^>]*)>',
    caseSensitive: false,
  );

  static final _imgRegexSingle = RegExp(
    r"<img([^>]*)\s+src='([^']+)'([^>]*)>",
    caseSensitive: false,
  );

  static final _base64ImageRegexDouble = RegExp(
    r'<img([^>]*)\s+src="(data:image/([^;]+);base64,([^"]+))"([^>]*)>',
    caseSensitive: false,
  );

  static final _base64ImageRegexSingle = RegExp(
    r"<img([^>]*)\s+src='(data:image/([^;]+);base64,([^']+))'([^>]*)>",
    caseSensitive: false,
  );

  static final _cloudinaryUrlRegex = RegExp(
    r'https://res\.cloudinary\.com/[^/]+/image/upload/(?:[^/]+/)?(.+)',
    caseSensitive: false,
  );

  /// Kiểm tra xem URL đã là full URL chưa
  static bool _isFullUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Kiểm tra xem URL là data URL (base64) chưa
  static bool _isDataUrl(String url) {
    return url.startsWith('data:');
  }

  /// Xử lý ảnh base64 trong HTML: upload lên server và thay thế bằng path
  ///
  /// [html] - HTML content chứa ảnh base64
  /// [eventRepository] - Repository để upload ảnh
  ///
  /// Returns: HTML với ảnh base64 đã được thay thế bằng path từ server
  /// Throws: Exception nếu upload thất bại
  static Future<String> processBase64ImagesInHtml(
    String html,
    EventRepository eventRepository,
  ) async {
    var processedHtml = html;

    // Xử lý double quotes
    final matchesDouble = _base64ImageRegexDouble
        .allMatches(processedHtml)
        .toList();
    for (final match in matchesDouble) {
      processedHtml = await _processBase64Match(
        match,
        processedHtml,
        eventRepository,
        isDoubleQuote: true,
      );
    }

    // Xử lý single quotes
    final matchesSingle = _base64ImageRegexSingle
        .allMatches(processedHtml)
        .toList();
    for (final match in matchesSingle) {
      processedHtml = await _processBase64Match(
        match,
        processedHtml,
        eventRepository,
        isDoubleQuote: false,
      );
    }

    return processedHtml;
  }

  /// Xử lý một match base64 image
  static Future<String> _processBase64Match(
    RegExpMatch match,
    String html,
    EventRepository eventRepository, {
    required bool isDoubleQuote,
  }) async {
    final beforeSrc = match.group(1) ?? '';
    final imageFormat = match.group(3) ?? 'jpeg';
    final base64Data = match.group(4) ?? '';
    final afterSrc = match.group(5) ?? '';

    try {
      // Decode base64 thành bytes
      final imageBytes = base64Decode(base64Data);

      // Tạo file tạm
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.$imageFormat',
      );
      await tempFile.writeAsBytes(imageBytes);

      // Upload lên server
      final xFile = XFile(tempFile.path);
      final uploadedUrl = await eventRepository.uploadImage(xFile);

      // Thay thế data URL bằng path từ server
      final quote = isDoubleQuote ? '"' : "'";
      final replacement =
          '<img$beforeSrc src=$quote$uploadedUrl$quote$afterSrc>';
      final processedHtml = html.replaceFirst(match.group(0)!, replacement);

      // Xóa file tạm
      await tempFile.delete();

      return processedHtml;
    } catch (e) {
      // Xóa file tạm nếu có lỗi
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.$imageFormat',
        );
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
      throw Exception('Không thể upload ảnh: $e');
    }
  }

  /// Convert path ảnh thành full Cloudinary URL để hiển thị
  ///
  /// [html] - HTML content chứa path ảnh
  ///
  /// Returns: HTML với path đã được convert thành Cloudinary URL
  static String convertImagePathsToUrls(String html) {
    var processedHtml = html;

    // Xử lý double quotes
    processedHtml = processedHtml.replaceAllMapped(
      _imgRegexDouble,
      (match) => _convertPathToUrl(match as RegExpMatch, isDoubleQuote: true),
    );

    // Xử lý single quotes
    processedHtml = processedHtml.replaceAllMapped(
      _imgRegexSingle,
      (match) => _convertPathToUrl(match as RegExpMatch, isDoubleQuote: false),
    );

    return processedHtml;
  }

  /// Convert một match path thành URL
  static String _convertPathToUrl(
    RegExpMatch match, {
    required bool isDoubleQuote,
  }) {
    final beforeSrc = match.group(1) ?? '';
    final src = match.group(2) ?? '';
    final afterSrc = match.group(3) ?? '';

    // Nếu đã là full URL hoặc data URL thì giữ nguyên
    if (_isFullUrl(src) || _isDataUrl(src)) {
      return match.group(0)!;
    }

    // Convert path thành full Cloudinary URL
    final cloudinaryUrl = CloudinaryImageService.getDescriptionImageUrl(src);
    final quote = isDoubleQuote ? '"' : "'";

    return '<img$beforeSrc src=$quote$cloudinaryUrl$quote$afterSrc>';
  }

  /// Convert full Cloudinary URL về path để lưu vào database
  ///
  /// [html] - HTML content chứa Cloudinary URLs
  ///
  /// Returns: HTML với Cloudinary URLs đã được convert về path
  static String convertImageUrlsToPaths(String html) {
    var processedHtml = html;

    // Xử lý double quotes
    processedHtml = processedHtml.replaceAllMapped(
      _imgRegexDouble,
      (match) => _convertUrlToPath(match as RegExpMatch, isDoubleQuote: true),
    );

    // Xử lý single quotes
    processedHtml = processedHtml.replaceAllMapped(
      _imgRegexSingle,
      (match) => _convertUrlToPath(match as RegExpMatch, isDoubleQuote: false),
    );

    return processedHtml;
  }

  /// Convert một match URL thành path
  static String _convertUrlToPath(
    RegExpMatch match, {
    required bool isDoubleQuote,
  }) {
    final beforeSrc = match.group(1) ?? '';
    final src = match.group(2) ?? '';
    final afterSrc = match.group(3) ?? '';

    // Nếu là Cloudinary URL thì extract path
    final cloudinaryMatch = _cloudinaryUrlRegex.firstMatch(src);
    if (cloudinaryMatch != null) {
      final path = cloudinaryMatch.group(1) ?? src;
      final quote = isDoubleQuote ? '"' : "'";
      return '<img$beforeSrc src=$quote$path$quote$afterSrc>';
    }

    // Nếu là data URL hoặc path khác thì giữ nguyên
    return match.group(0)!;
  }

  /// Convert path ảnh thành full Cloudinary URL (alias cho convertImagePathsToUrls)
  /// Dùng cho view HTML content
  static String processHtmlImagesForView(String html) {
    return convertImagePathsToUrls(html);
  }
}
