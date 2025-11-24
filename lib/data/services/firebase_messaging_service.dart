import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_frontend/data/services/notification_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();
  
  Function(Map<String, dynamic>)? onNotificationReceived;

  /// Inicializa Firebase Messaging
  Future<void> initialize() async {
    // ✅ PASO 1: Solicitar permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted FCM permission');
      
      // ✅ PASO 2: Configurar notificaciones locales PRIMERO
      await _setupLocalNotifications();
      
      // ✅ PASO 3: Obtener y registrar token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('📱 FCM Token: $token');
        await _registerToken(token);
      }
      
      // ✅ PASO 4: Escuchar actualización de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _registerToken(newToken);
      });
      
      // ✅ PASO 5: Manejar mensajes en FOREGROUND (app abierta)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // ✅ PASO 6: Manejar click en notificación (app en background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // ✅ PASO 7: Verificar si app se abrió desde notificación
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 App opened from notification');
        _handleNotificationTap(initialMessage);
      }
    } else {
      print('❌ User declined FCM permission');
    }
  }

  /// ✅ Configura las notificaciones locales
  Future<void> _setupLocalNotifications() async {
    // Android settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // ✅ Inicializar con callback para manejar clicks
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 Notification clicked: ${response.payload}');
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          onNotificationReceived?.call(data);
        }
      },
    );
    
    // ✅ CRÍTICO: Crear canal de Android con IMPORTANCIA ALTA
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID debe coincidir con AndroidManifest.xml
      'Notificaciones importantes',
      description: 'Canal para notificaciones importantes de recordatorios',
      importance: Importance.high, // ✅ CRÍTICO: Importancia ALTA
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    // ✅ Crear el canal en el sistema Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      print('✅ Android notification channel created');
    }
  }

  /// Registra el token FCM en el backend
  Future<void> _registerToken(String token) async {
    try {
      await _notificationService.registerDeviceToken(token);
      print('✅ Token registered successfully');
    } catch (e) {
      print('❌ Error registering fcm_token: $e');
    }
  }

  /// ✅ Maneja mensajes cuando la app está EN FOREGROUND (abierta)
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Got message in FOREGROUND');
    print('📩 Title: ${message.notification?.title}');
    print('📩 Body: ${message.notification?.body}');
    print('📩 Data: ${message.data}');
    
    // ✅ MOSTRAR notificación local cuando app está abierta
    if (message.notification != null) {
      _showLocalNotification(
        message.notification!.title ?? 'Notificación',
        message.notification!.body ?? '',
        message.data,
      );
    }
    
    // Notificar a la app para actualizar UI
    onNotificationReceived?.call(message.data);
  }

  /// Maneja cuando el usuario toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped!');
    print('📩 Data: ${message.data}');
    
    // Notificar a la app para navegar
    onNotificationReceived?.call(message.data);
  }

  /// ✅ Muestra una notificación local en el dispositivo
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    // ✅ Configuración Android con PRIORIDAD ALTA
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // ✅ Debe coincidir con el canal creado
      'Notificaciones importantes',
      channelDescription: 'Canal para notificaciones importantes',
      importance: Importance.high, // ✅ CRÍTICO
      priority: Priority.high, // ✅ CRÍTICO
      showWhen: true,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher', // ✅ Usar el ícono de la app
    );
    
    // iOS configuration
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // ✅ Mostrar notificación
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    await _localNotifications.show(
      notificationId, // ID único basado en timestamp
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
    
    print('✅ Local notification shown: $title');
  }

  /// Elimina el token al hacer logout
  Future<void> unregisterToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _notificationService.unregisterDeviceToken(token);
        await _firebaseMessaging.deleteToken();
        print('✅ Token unregistered successfully');
      }
    } catch (e) {
      print('❌ Error unregistering token: $e');
    }
  }
}