class AuthResponse {
  final String accessToken;
  final String expiresAt;
  final String userId;
  final String fullName;
  final List<String> roles;

  AuthResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.userId,
    required this.fullName,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] as String,
    expiresAt: json['expiresAt'] as String,
    userId: json['userId'] as String,
    fullName: json['fullName'] as String,
    roles: List<String>.from(json['roles'] as List),
  );
}
