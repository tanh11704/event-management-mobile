import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'https://api.fallback.com';
  }
}
