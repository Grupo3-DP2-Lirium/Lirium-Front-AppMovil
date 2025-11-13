import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/auth_service.dart';
import 'package:flutter_frontend/data/services/auth_storage.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/data/services/notification_service.dart';
import 'package:flutter_frontend/presentation/screens/main/main_navigation_screen.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../data/services/storage_service.dart';
import '../../components/components.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:flutter_frontend/config/api_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  final httpService = HttpService();
  final storage = AuthStorage();
  final notificationService = NotificationService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    } else {
      _loadLastEmail();
    }
  }

  Future<void> _loadLastEmail() async {
    final lastEmail = await storage.getLastEmail();
    if (!mounted) return;
    if (lastEmail != null && lastEmail.isNotEmpty) {
      setState(() {
        _emailController.text = lastEmail;
      });
    }
  }

  Future<void> _registerFCMToken() async {
    try {
      print('📱 Starting FCM token registration...');

      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('🔔 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();

        if (token != null && token.isNotEmpty) {
          print('✅ FCM Token obtained: ${token.substring(0, 20)}...');
          await notificationService.registerDeviceToken(token);
          print('✅ FCM Token registered in backend successfully');
        } else {
          print('⚠️ Failed to obtain FCM token');
        }
      } else {
        print('❌ Notification permissions not granted: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ Error registering FCM token: $e');
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final access = (data['accessToken'] ?? data['token']) as String?;
        final refresh = (data['refreshToken'] ?? data['refresh_token']) as String?;

        if (access == null || access.isEmpty) {
          _showMessage('No se recibió accessToken');
          return;
        }

        final token = data['token'] as String;
        final plan = data['plan'] ?? 'FREE';
        final permissions = List<String>.from(data['permissions'] ?? []);
        final extraStorageData = data['extraStorageSubscriptions'] as List<dynamic>? ?? [];
        final extraStorages = extraStorageData.map((e) => {
          'planName': e['planName'],
          'additionalStorageGb': e['additionalStorageGb'],
          'status': e['status'],
        }).toList();

        print("Token recibido: $token");
        print("Plan recibido del back: $plan");
        print("Permisos recibidos: $permissions");
        print("Extra storages guardados: $extraStorages");

        await StorageService.savePlan(plan);
        await StorageService.savePermissions(permissions);
        await StorageService.saveExtraStorageSubscriptions(extraStorages);

        httpService.setToken(access);
        await storage.save(access: access, refresh: refresh);
        await storage.saveLastEmail(_emailController.text);

        // CRÍTICO: Registrar token FCM DESPUÉS del login exitoso
        await _registerFCMToken();

        _showMessage('¡Login exitoso!');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      } else if (response.statusCode == 401) {
        _showMessage('Credenciales incorrectas');
      } else {
        _showMessage('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              const AppTitle(title: 'Inicia sesión'),
              const SizedBox(height: 40),

              // Email field con CustomTextField
              CustomTextField(
                label: 'Correo electrónico',
                hintText: 'Tu correo@ejemplo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                onChanged: (value) {
                  storage.saveLastEmail(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password field con CustomTextField
              CustomTextField(
                label: 'Contraseña',
                hintText: 'Tu contraseña',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: SecondaryButton(
                  text: '¿Olvidaste tu contraseña?',
                  textColor: AppColors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Login button
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : PrimaryButton(
                text: 'Iniciar',
                onPressed: _login,
              ),
              const SizedBox(height: 24),

              // Sign up link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SecondaryButton(
                      text: 'Crear cuenta',
                      textColor: AppColors.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}