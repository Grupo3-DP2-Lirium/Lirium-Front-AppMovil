class AppConfig {
  static const String appName = 'Lirium';
  static const String version = '1.0.0';

  // Configuración de timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos

  // Configuración de storage
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Configuración de paginación
  static const int defaultPageSize = 20;

  // Configuración de archivos
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
}