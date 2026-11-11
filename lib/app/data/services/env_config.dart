import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  /// Load the appropriate .env file based on build mode.
  /// Release builds use `.env.production`, debug/profile builds use `.env.local`.
  static Future<void> load() async {
    final envFile = kReleaseMode ? '.env.production' : '.env.local';
    await dotenv.load(fileName: envFile);
  }

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get siteUrl => dotenv.env['SITE_URL'] ?? '';
  static String get cdnUrl => dotenv.env['CDN_URL'] ?? '';
  static String get supportEmail => dotenv.env['SUPPORT_EMAIL'] ?? '';
  static String get supportPhone => dotenv.env['SUPPORT_PHONE'] ?? '';
}
