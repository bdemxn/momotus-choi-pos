class UserModel {
  final String token;
  final String tokenType;
  final String role;
  final String fullname;
  final String expiresAt;

  UserModel(
      {required this.expiresAt,
      required this.token,
      required this.tokenType,
      required this.role,
      required this.fullname});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json['access_token'] == null || json['access_token'] is! String) {
      throw Exception("El campo 'access_token' es inválido o nulo.");
    }

    return UserModel(
      token: json['access_token'],
      tokenType: json['token_type'] ?? 'unknown',
      role: json['role'] ?? 'user',
      fullname: json['fullname'],
      expiresAt: json["expires_at"] ?? "unknown",
    );
  }
}
