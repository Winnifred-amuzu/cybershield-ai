class AuthSession {
  final String token;
  final int id;
  final String name;
  final String email;
  final String createdAt;

  const AuthSession({required this.token, required this.id, required this.name, required this.email, required this.createdAt});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = Map<String, dynamic>.from(json['user'] as Map);
    return AuthSession(token: json['access_token'] as String, id: user['id'] as int, name: user['name'] as String, email: user['email'] as String, createdAt: user['created_at'] as String);
  }
}
