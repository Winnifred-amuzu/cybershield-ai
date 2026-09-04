class ApiConfig {
  const ApiConfig._();

  /// API base URL can be overridden at build/run time with:
  ///
  /// flutter run --dart-define=CYBERSHIELD_API_URL=http://10.0.2.2:8000
  ///
  /// or:
  ///
  /// flutter build apk --release \
  ///   --dart-define=CYBERSHIELD_API_URL=https://your-api-domain
  ///
  /// The default remains the currently verified local development
  /// backend so existing development behavior is preserved.
  static const String serverUrl = String.fromEnvironment(
    'CYBERSHIELD_API_URL',
    defaultValue: '10.128.250.109',
  );

  static String get baseUrl {
    final normalized = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;

    return '$normalized/api';
  }

  static Uri endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static Uri healthEndpoint() {
    return Uri.parse('$serverUrl/health');
  }
}