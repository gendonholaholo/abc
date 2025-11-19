import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.maybeGet('API_BASE_URL') ??
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.com',
      );

  static Duration get defaultTimeout => const Duration(seconds: 10);
}
