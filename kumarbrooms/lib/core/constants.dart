import 'package:flutter/foundation.dart';

abstract final class AppConstants {
  static const appName = 'Kumar Brooms';

  // Android emulators reach the host machine through 10.0.2.2. Override this
  // for a real device or production with --dart-define=API_BASE_URL=...
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get apiBaseUrl => _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : kIsWeb
          ? 'http://localhost:8080'
          : defaultTargetPlatform == TargetPlatform.android
              ? 'http://10.0.2.2:8080'
              : 'http://localhost:8080';
}
