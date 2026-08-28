import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import 'api_config.dart';

class AuthService {
  static const _tokenKey = 'cybershield_access_token';
  static const _storage = FlutterSecureStorage();
  static const _timeout = Duration(seconds: 20);

  Future<AuthSession> login(String email, String password) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/auth/login'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'email': email.trim(),
            'password': password,
          }),
        )
        .timeout(_timeout);
    return _save(response);
  }

  Future<AuthSession> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/auth/register'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name.trim(),
            'email': email.trim(),
            'password': password,
          }),
        )
        .timeout(_timeout);
    return _save(response);
  }

  Future<String?> token() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String value) =>
      _storage.write(key: _tokenKey, value: value);

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<AuthSession> _save(http.Response response) async {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw const AuthException(
        'The server returned an invalid authentication response.',
      );
    }

    if (response.statusCode == 429) {
      throw const AuthException(
        'Too many authentication attempts. Please wait and try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = body is Map ? body['detail'] : null;
      throw AuthException(
        detail?.toString() ?? 'Authentication failed (${response.statusCode}).',
      );
    }

    if (body is! Map) {
      throw const AuthException('Invalid authentication response.');
    }

    final session = AuthSession.fromJson(Map<String, dynamic>.from(body));
    await saveToken(session.token);
    return session;
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
