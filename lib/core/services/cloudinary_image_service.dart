import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryImageService {
  CloudinaryImageService._();

  /// Cloudinary cloud name từ environment variable
  static String? get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'];

  /// Cloudinary base URL
  static String get _baseUrl {
    final cloudName = _cloudName ?? 'your-cloud-name';
    return 'https://res.cloudinary.com/$cloudName/image/upload';
  }

  /// Kiểm tra xem URL đã là full URL chưa
  static bool _isFullUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Build full Cloudinary URL từ path
  ///
  /// Nếu path đã là full URL thì trả về nguyên path
  /// Nếu path là relative path (ví dụ: "banners/banner_event_21_1763439748900.jpg")
  /// thì build thành full Cloudinary URL
  ///
  /// [path] - Path của ảnh từ database (có thể là full URL hoặc relative path)
  /// [transformations] - Optional Cloudinary transformations (ví dụ: "w_500,h_500")
  ///
  /// Ví dụ:
  /// - Input: "banners/banner_event_21_1763439748900.jpg"
  /// - Output: "https://res.cloudinary.com/{cloud_name}/image/upload/banners/banner_event_21_1763439748900.jpg"
  ///
  /// - Input: "banners/banner_event_21_1763439748900.jpg", transformations: "w_500,h_500"
  /// - Output: "https://res.cloudinary.com/{cloud_name}/image/upload/w_500,h_500/banners/banner_event_21_1763439748900.jpg"
  static String getImageUrl(String? path, {String? transformations}) {
    if (path == null || path.isEmpty) {
      return '';
    }

    // Nếu đã là full URL thì trả về nguyên
    if (_isFullUrl(path)) {
      return path;
    }

    // Build Cloudinary URL
    final baseUrl = _baseUrl;
    if (transformations != null && transformations.isNotEmpty) {
      return '$baseUrl/$transformations/$path';
    }
    return '$baseUrl/$path';
  }

  /// Build Cloudinary URL với transformations mặc định cho banner
  /// (tối ưu kích thước và chất lượng)
  static String getBannerUrl(String? path) {
    return getImageUrl(path, transformations: 'w_1920,h_1080,c_fill,q_auto');
  }

  /// Build Cloudinary URL với transformations mặc định cho thumbnail
  static String getThumbnailUrl(String? path) {
    return getImageUrl(path, transformations: 'w_400,h_300,c_fill,q_auto');
  }

  /// Build Cloudinary URL với transformations mặc định cho ảnh trong mô tả
  static String getDescriptionImageUrl(String? path) {
    return getImageUrl(path, transformations: 'w_800,c_limit,q_auto');
  }
}
