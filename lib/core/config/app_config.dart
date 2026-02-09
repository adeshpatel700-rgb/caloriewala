/// App-wide constants and configuration
class AppConfig {
  // App Information
  static const String appName = 'CalorieWala';
  static const String appTagline = 'Your AI Food Nutrition Companion';
  static const String packageName = 'com.caloriewala.app';

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Free Tier Limits
  static const int freeAnalysesPerDay = 10;
  static const bool isPremiumEnabled = false; // For future monetization

  // Storage Keys
  static const String hiveBoxMeals = 'meals';
  static const String hiveBoxSettings = 'settings';
  static const String keyThemeMode = 'theme_mode';
  static const String keyDailyUsageCount = 'daily_usage_count';
  static const String keyLastUsageDate = 'last_usage_date';

  // Medical Disclaimer
  static const String medicalDisclaimer =
      'CalorieWala provides approximate nutritional estimates for informational purposes only. '
      'These estimates are not a substitute for professional medical or dietary advice. '
      'Actual values may vary based on ingredients, cooking methods, and portion sizes. '
      'Please consult a healthcare provider or registered dietitian for personalized dietary guidance.';

  // Short Disclaimer
  static const String shortDisclaimer =
      'Approximate estimates • Not medical advice';

  // Image Analysis
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 85;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}
