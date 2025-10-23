import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/firebase_messaging_service.dart';
import 'package:flutter_frontend/presentation/screens/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/memorial_provider.dart';
import 'presentation/screens/memorial/memorials_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// ✅ Maneja mensajes en background (cuando la app está cerrada)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message: ${message.messageId}');
  print('📩 Title: ${message.notification?.title}');
  print('📩 Body: ${message.notification?.body}');
  print('📩 Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // ✅ Configurar handler de mensajes en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const RemoryApp());
}

class RemoryApp extends StatefulWidget {
  const RemoryApp({super.key});

  @override
  State<RemoryApp> createState() => _RemoryAppState();
}

class _RemoryAppState extends State<RemoryApp> {
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // ✅ PASO 1: Solicitar permisos de notificación (Android 13+)
    await _requestNotificationPermissions();
    
    // ✅ PASO 2: Inicializar Firebase Messaging
    await _initializeFirebaseMessaging();
  }

  /// ✅ Solicita permisos de notificación al usuario
  Future<void> _requestNotificationPermissions() async {
    final status = await Permission.notification.status;
    
    print('🔔 Notification permission status: $status');
    
    if (status.isDenied) {
      final result = await Permission.notification.request();
      
      if (result.isGranted) {
        print('✅ Notification permission GRANTED');
      } else if (result.isPermanentlyDenied) {
        print('⚠️ Notification permission PERMANENTLY DENIED');
        // Opcional: Mostrar diálogo para abrir configuración
        // await openAppSettings();
      } else {
        print('❌ Notification permission DENIED');
      }
    } else if (status.isGranted) {
      print('✅ Notification permission already granted');
    } else if (status.isPermanentlyDenied) {
      print('⚠️ Notification permission permanently denied - need to open settings');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    await _fcmService.initialize();
    
    // ✅ Configurar callback para manejar notificaciones
    _fcmService.onNotificationReceived = (data) {
      print('📬 Notification received in app: $data');
      final type = data['type'];
      
      switch (type) {
        case 'REMINDER':
          print('🔔 Reminder notification: ${data['reminderId']}');
          // TODO: Navegar a recordatorios o mostrar detalles
          break;
        case 'COMMENT':
          final memorialId = data['memorialId'];
          print('💬 Comment notification for memorial: $memorialId');
          // TODO: Navegar al memorial específico
          break;
        case 'LIKE':
          print('❤️ Like notification');
          // TODO: Navegar a la memoria que recibió like
          break;
        default:
          print('📨 Other notification type: $type');
          break;
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemorialProvider()),
      ],
      child: MaterialApp(
        title: 'Remory',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            primary: const Color(0xFF6366F1),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme().copyWith(
            displayLarge: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
            displayMedium: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            displaySmall: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            bodyLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            bodyMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            bodySmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
        home: const LoginScreen(),
        routes: {
          '/memorials': (_) => const MemorialsScreen(),
        },
      ),
    );
  }
}