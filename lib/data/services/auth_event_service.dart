import 'dart:async';

/// Eventos de autenticación
enum AuthEvent {
  accountSuspended,
  tokenExpired,
  loggedOut,
}

/// Servicio para manejar eventos de autenticación globalmente
class AuthEventService {
  static final AuthEventService _instance = AuthEventService._internal();
  factory AuthEventService() => _instance;
  AuthEventService._internal();

  final _controller = StreamController<AuthEvent>.broadcast();

  /// Stream de eventos de autenticación
  Stream<AuthEvent> get events => _controller.stream;

  /// Emitir un evento
  void emit(AuthEvent event) {
    print('🔔 AuthEventService: Emitiendo evento $event');
    print('🔔 AuthEventService: Tiene listeners: ${_controller.hasListener}');
    _controller.add(event);
    print('🔔 AuthEventService: Evento emitido exitosamente');
  }

  /// Cerrar el stream
  void dispose() {
    _controller.close();
  }
}
