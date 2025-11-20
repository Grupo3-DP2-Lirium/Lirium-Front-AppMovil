import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/firebase_messaging_service.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/auth/login_screen.dart';
import 'package:flutter_frontend/presentation/widgets/auth_listener_wrapper.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/memorial_provider.dart';
import 'presentation/screens/memorial/memorials_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
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

Future<void> main() async {
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
    // ✅ Paso 1: Solicitar permisos de notificación (Android 13+)
    await _requestNotificationPermissions();

    // ✅ Paso 2: Inicializar Firebase Messaging
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
        // Puedes abrir la configuración si lo deseas:
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

    // ✅ Configurar callback para manejar notificaciones recibidas
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
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => DocumentaryProvider()),
        ChangeNotifierProvider(create: (_) => CapsuleProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider())
      ],
      child: MaterialApp(
        title: 'Lirium',
        debugShowCheckedModeBanner: false,

        // ✨ CONFIGURACIÓN DEL THEME CON INTER
        theme: ThemeData(
          // Fuente principal
          fontFamily: 'Inter',

          // Color primario
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),

          // Configuración de texto con Inter
          textTheme: const TextTheme(
            // Headings
            displayLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 42,
              fontWeight: FontWeight.w800, // ExtraBold
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 36,
              fontWeight: FontWeight.w700, // Bold
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            displaySmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w600, // SemiBold
              color: AppColors.textPrimary,
            ),

            // H1-H6 equivalentes
            headlineLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w600, // SemiBold
              color: AppColors.textPrimary,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w600, // SemiBold
              color: AppColors.textPrimary,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600, // SemiBold
              color: AppColors.textPrimary,
            ),

            // Body Text
            bodyLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w400, // Regular
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400, // Regular
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400, // Regular
              color: AppColors.textSecondary,
              height: 1.5,
            ),

            // Labels
            labelLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500, // Medium
              color: AppColors.textPrimary,
            ),
            labelMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500, // Medium
              color: AppColors.textPrimary,
            ),
            labelSmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500, // Medium
              color: AppColors.textSecondary,
            ),
          ),

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            // Se aplicará automáticamente a todos los TextFormField
            labelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            floatingLabelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
          ),

          // AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
          ),

          // Text Button Theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        //debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
        // ✅ Envolver TODA la app con AuthListenerWrapper
        builder: (context, child) {
          return AuthListenerWrapper(
            child: child ?? const SizedBox(),
          );
        },
        home: const LoginScreen(),
        routes: {
          '/memorials': (_) => const MemorialsScreen(),
        },
      ),
    );
  }
}