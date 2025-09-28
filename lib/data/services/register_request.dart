class RegisterRequest {
  final String firstName;
  final String firstLastName;
  final String? secondLastName;
  final String email;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.firstLastName,
    this.secondLastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'firstLastName': firstLastName,
    'secondLastName': secondLastName,
    'email': email,
    'password': password,
  };
}
