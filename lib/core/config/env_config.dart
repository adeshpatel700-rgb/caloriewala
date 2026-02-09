import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
class EnvConfig {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get groqBaseUrl =>
      dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
  static String get visionModel =>
      dotenv.env['VISION_MODEL'] ?? 'meta-llama/llama-4-scout-17b-16e-instruct';
  static String get textModel =>
      dotenv.env['TEXT_MODEL'] ?? 'llama-3.3-70b-versatile';

  /// Validate that all required environment variables are set
  static bool validate() {
    if (groqApiKey.isEmpty) {
      return false;
    }
    return true;
  }

  /// Check if API key is configured
  static bool get isConfigured => groqApiKey.isNotEmpty;
}
