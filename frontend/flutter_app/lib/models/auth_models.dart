class AuthUser {
  final String id;
  final String email;
  final String? fullName;
  final bool isActive;

  AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.isActive,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as String,
        email: j['email'] as String,
        fullName: j['full_name'] as String?,
        isActive: j['is_active'] as bool? ?? true,
      );
}

class AuthTokenResponse {
  final String accessToken;
  final AuthUser user;

  AuthTokenResponse({required this.accessToken, required this.user});

  factory AuthTokenResponse.fromJson(Map<String, dynamic> j) => AuthTokenResponse(
        accessToken: j['access_token'] as String,
        user: AuthUser.fromJson(j['user'] as Map<String, dynamic>),
      );
}
