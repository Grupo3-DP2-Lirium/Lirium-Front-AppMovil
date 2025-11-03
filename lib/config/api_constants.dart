import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configuración dinámica para web, emulador y móvil físico
  static String get baseUrl {
    if (kIsWeb) {
      // Para navegador web (Chrome, Firefox, etc.)
      return "http://localhost:8080/api";
    } else {
      // Para celular físico en la misma red Wi-Fi
      //return "http://192.168.18.177:8080/api"; // <- tu IP de Wi-Fi
      // Si quisieras seguir usando el emulador:
      return "http://10.0.2.2:8080/api";
    }
  }

  // Endpoints de autenticación
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get verifyCode => '$baseUrl/auth/verify-code';
  static String get resetPassword => '$baseUrl/auth/reset-password';

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

  // Endpoints de reflexiones
  static String get reflections => '$baseUrl/reflections';
  static String get reflectionSearch => '$baseUrl/reflections/search';
  static String get reflectionStats => '$baseUrl/reflections/stats';

  // Endpoints de documentales
  static String get documentaries => '$baseUrl/documentaries';
  static String get myDocumentaries => '$baseUrl/documentaries/my-documentaries';
  static String get musicCatalog => '$baseUrl/documentaries/music-catalog';
}
