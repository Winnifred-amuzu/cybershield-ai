class ApiConfig {
  const ApiConfig._();

  // IMPORTANT:
  // This must be the IP address of the computer running the FastAPI backend.
  //
  // Your backend has already been verified at:
  // http://192.168.10.182:8000
  //
  // The Android phone and computer must be connected to the same network.
  static const String baseUrl = 'http://192.168.10.182:8000/api';

  static Uri endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static Uri healthEndpoint() {
    return Uri.parse('http://192.168.10.182:8000/health');
  }
}