class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final List<String> roles;
  final int? id;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.roles,
    this.id,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rolesJson = json['role'] as List;
    final rolesList = rolesJson.map((r) => r['authority'] as String).toList();
    return LoginResponse(
      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
      email: json["email"],
      roles: rolesList,
      id: json["id"] as int?,
    );
  }
}
