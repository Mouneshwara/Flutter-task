class AppConfig {
  AppConfig._();

  // Android emulator uses 10.0.2.2 to reach the host computer.
  // Override with: --dart-define=API_BASE_URL=http://localhost:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
