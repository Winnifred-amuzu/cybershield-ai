import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dashboard_data.dart';
import '../models/detection_result.dart';
import '../models/model_performance.dart';
import '../models/scan_record.dart';
import '../models/url_analysis.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() => message;
}

class ApiService {
  const ApiService();

  static const ApiService instance = ApiService();

  static final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers({
    bool authenticated = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await _auth.token();

      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }
    }

    return headers;
  }

  Future<dynamic> _decodeResponse(http.Response response) async {
    dynamic decoded;

    if (response.body.trim().isEmpty) {
      decoded = null;
    } else {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw ApiException(
          'The server returned an invalid response.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decoded;
    }

    String message =
        'Request failed (${response.statusCode}).';

    if (decoded is Map) {
      final detail = decoded['detail'];

      if (detail != null) {
        message = detail.toString();
      }
    }

    if (response.statusCode == 401) {
      message = 'Authentication required. Please sign in again.';
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
    );
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.endpoint('/auth/register'),
      headers: await _headers(authenticated: false),
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid registration response from server.',
      );
    }

    final data = Map<String, dynamic>.from(decoded);

    final token = data['access_token']?.toString();

    if (token != null && token.isNotEmpty) {
      await _auth.saveToken(token);
    }

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.endpoint('/auth/login'),
      headers: await _headers(authenticated: false),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid login response from server.',
      );
    }

    final data = Map<String, dynamic>.from(decoded);

    final token = data['access_token']?.toString();

    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Login succeeded but the server did not return an access token.',
      );
    }

    await _auth.saveToken(token);

    return data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      ApiConfig.endpoint('/auth/me'),
      headers: await _headers(),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid user response from server.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<bool> isAuthenticated() async {
    final token = await _auth.token();

    if (token == null || token.trim().isEmpty) {
      return false;
    }

    try {
      await getCurrentUser();
      return true;
    } catch (_) {
      await _auth.logout();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
  }

  // ---------------------------------------------------------------------------
  // MESSAGE DETECTION
  // ---------------------------------------------------------------------------

  Future<DetectionResult> detect({
    required String message,
    required String source,
  }) async {
    final cleanedMessage = message.trim();
    final cleanedSource = source.trim();

    if (cleanedMessage.isEmpty) {
      throw const ApiException(
        'Enter a message before analysing it.',
      );
    }

    final response = await http.post(
      ApiConfig.endpoint('/mobile/detect'),
      headers: await _headers(),
      body: jsonEncode({
        'message': cleanedMessage,
        'source': cleanedSource,
      }),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid detection response from server.',
      );
    }

    return DetectionResult.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  // Backward-compatible method name.
  Future<DetectionResult> detectMessage({
    required String message,
    required String source,
  }) {
    return detect(
      message: message,
      source: source,
    );
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD
  // ---------------------------------------------------------------------------

  Future<DashboardData> getDashboard() async {
    final response = await http.get(
      ApiConfig.endpoint('/mobile/dashboard'),
      headers: await _headers(),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid dashboard response from server.',
      );
    }

    return DashboardData.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  // ---------------------------------------------------------------------------
  // HISTORY
  // ---------------------------------------------------------------------------

  Future<List<ScanRecord>> getHistory({
    int limit = 100,
  }) async {
    final safeLimit = limit.clamp(1, 200);

    final response = await http.get(
      ApiConfig.endpoint(
        '/mobile/history?limit=$safeLimit',
      ),
      headers: await _headers(),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! List) {
      throw const ApiException(
        'Invalid history response from server.',
      );
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => ScanRecord.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // MODEL PERFORMANCE
  // ---------------------------------------------------------------------------

  Future<List<ModelPerformance>> getModelPerformance() async {
    final response = await http.get(
      ApiConfig.endpoint('/model/performance'),
      headers: await _headers(authenticated: false),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! List) {
      throw const ApiException(
        'Invalid model performance response from server.',
      );
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => ModelPerformance.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // MODEL STATUS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getModelStatus() async {
    final response = await http.get(
      ApiConfig.endpoint('/model/status'),
      headers: await _headers(authenticated: false),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid model status response from server.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  // ---------------------------------------------------------------------------
  // SYSTEM HEALTH
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getSystemHealth() async {
    final response = await http.get(
      ApiConfig.healthEndpoint(),
      headers: await _headers(authenticated: false),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid health response from server.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        ApiConfig.healthEndpoint(),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // URL ANALYSIS
  // ---------------------------------------------------------------------------

  Future<UrlAnalysis> analyzeUrl(String url) async {
    final cleanedUrl = url.trim();

    if (cleanedUrl.isEmpty) {
      throw const ApiException(
        'Please enter a URL.',
      );
    }

    final response = await http.post(
      ApiConfig.endpoint('/url/analyze'),
      headers: await _headers(authenticated: false),
      body: jsonEncode({
        'url': cleanedUrl,
      }),
    );

    final decoded = await _decodeResponse(response);

    if (decoded is! Map) {
      throw const ApiException(
        'Invalid URL analysis response from server.',
      );
    }

    return UrlAnalysis.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }
}