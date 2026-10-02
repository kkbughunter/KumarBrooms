abstract final class AppConstants {
  static const appName = 'Kumar Brooms';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://kumarbrooms.astraval.com:8080',
  );
}
