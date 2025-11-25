import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryImageService {
  CloudinaryImageService._();

  static String? get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'];

  static String get _baseUrl {
    final cloudName = _cloudName ?? 'your-cloud-name';
    return 'https://res.cloudinary.com/$cloudName/image/upload';
  }

  static bool _isFullUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static String getImageUrl(String? path, {String? transformations}) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (_isFullUrl(path)) {
      return path;
    }

    final baseUrl = _baseUrl;
    if (transformations != null && transformations.isNotEmpty) {
      return '$baseUrl/$transformations/$path';
    }
    return '$baseUrl/$path';
  }

  static String getBannerUrl(String? path) {
    return getImageUrl(path, transformations: 'w_1920,h_1080,c_fill,q_auto');
  }

  static String getThumbnailUrl(String? path) {
    return getImageUrl(path, transformations: 'w_400,h_300,c_fill,q_auto');
  }

  static String getDescriptionImageUrl(String? path) {
    return getImageUrl(path, transformations: 'w_800,c_limit,q_auto');
  }
}
