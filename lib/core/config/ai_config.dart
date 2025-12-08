class AiConfig {
  static const String baseUrl = String.fromEnvironment(
    'AI_SERVICE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration timeout = Duration(seconds: 30);
  static const Duration batchTimeout = Duration(seconds: 60);
  static const int maxRetries = 3;

  static bool get isEnabled =>
      const bool.fromEnvironment('AI_ENABLED', defaultValue: true);
}
