class LoginResponse {
  final String token; // asumiendo que tu backend devuelve un JWT
  final String firstName;
  final String email;

  LoginResponse({
    required this.token,
    required this.firstName,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json["token"],
      firstName: json["firstName"],
      email: json["email"],
    );
  }
}
