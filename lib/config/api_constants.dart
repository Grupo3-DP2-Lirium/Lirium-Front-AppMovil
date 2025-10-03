import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configuración dinámica para web vs móvil
  static String get baseUrl {
    if (kIsWeb) {
      // Para navegador web (Chrome, Firefox, etc.)
      return "http://localhost:8080/api";
    } else {
      // Para Android emulator
      return "http://10.0.2.2:8080/api";
    }
  }

  // Endpoints de autenticación
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';

  // Endpoints de memoriales
  static String get memorials => '$baseUrl/memorials';
  static String get collaborativeMemorials =>
      '$baseUrl/memorials/collaborative';
  static String get getCollaborativeMemorials =>
      '$baseUrl/memorials/getCollaborativeMemorials';
  static String get predefinedQuestions =>
      '$baseUrl/memorials/predefined-questions';

  // Endpoints de memorias
  static String get memories => '$baseUrl/memories';
}
