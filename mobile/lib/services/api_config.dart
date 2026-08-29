class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'http://192.168.10.180:8000/api';

  static Uri endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static Uri healthEndpoint() {
    return Uri.parse('http://192.168.10.180:8000/health');
  }
}