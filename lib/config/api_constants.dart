class ApiConstants {
  //static const String baseUrl = "http://localhost:8080/api";
  static const String baseUrl = "http://10.0.2.2:8080/api";

// Endpoints de autenticación
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Endpoints de memoriales
  static const String memorials = '$baseUrl/memorials';
  static const String collaborativeMemorials = '$baseUrl/memorials/collaborative';
  static const String predefinedQuestions = '$baseUrl/memorials/predefined-questions';

  // Endpoints de memorias
  static const String memories = '$baseUrl/memories';
}
