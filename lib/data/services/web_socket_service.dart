import 'package:flutter_frontend/config/api_constants.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? _stompClient;

  void connect(String token, void Function(String message) onMessage) {
    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (StompFrame frame) {
          print("✅ Conectado a WebSocket");

          // Suscribirse a notificaciones del usuario
          // Ahora el backend usará el token para determinar a quién enviar
          _stompClient!.subscribe(
            destination: '/user/topic/notifications',
            callback: (frame) {
              if (frame.body != null) {
                onMessage(frame.body!);
              }
            },
          );
        },
        onStompError: (frame) => print("❌ Error STOMP: ${frame.body}"),
        onWebSocketError: (dynamic error) => print("❌ Error WS: $error"),
        stompConnectHeaders: {
          'Authorization': 'Bearer $token', // 👈 PASAMOS EL TOKEN
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token', // 👈 PASAMOS EL TOKEN
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}
