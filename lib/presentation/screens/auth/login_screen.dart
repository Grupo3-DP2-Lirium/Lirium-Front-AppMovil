import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/auth_service.dart';
import 'package:flutter_frontend/data/services/auth_storage.dart';
import 'package:flutter_frontend/data/services/http_service.dart';
import 'package:flutter_frontend/presentation/screens/main/main_navigation_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../components/components.dart';
import '../setup/preserve_question_screen.dart';
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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

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

  // Función para hacer login con el backend
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

        // recibir token
        final access = (data['accessToken'] ?? data['token']) as String?;
        final refresh = (data['refreshToken'] ?? data['refresh_token']) as String?;

        if (access == null || access.isEmpty) {
          _showMessage('No se recibió accessToken');
          return;
        }

        httpService.setToken(access);                 // usa el token en el HttpService
        await storage.save(access: access, refresh: refresh); // persiste seguro
        await storage.saveLastEmail(_emailController.text); // asegura guardar el último correo

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

  // Función para crear un usuario de prueba con las credenciales que quieres
  Future<void> _createTestUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': 'Rodrigo',
          'firstLastName': 'Usuario',
          'email': 'rodrigo@test.com',  // Cambié el email para evitar conflictos
          'password': 'rodrigo',  // La contraseña que quieres usar
        }),
      );

      if (response.statusCode == 201) {
        _showMessage('¡Usuario creado! Email: rodrigo@test.com, Password: rodrigo');
        // Prellenar los campos automáticamente
        _emailController.text = 'rodrigo@test.com';
        _passwordController.text = 'rodrigo';
      } else {
        _showMessage('Error creando usuario: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title
              const AppTitle(title: 'Inicia sesión'),
              const SizedBox(height: 40),
              // Email field
              AppTextField(
                hintText: 'Tu correo@ejemplo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                onChanged: (value) {
                  // Guardar el último correo en tiempo real
                  storage.saveLastEmail(value);
                },
              ),
              const SizedBox(height: 16),
              // Password field
              PasswordField(controller: _passwordController),
              const SizedBox(height: 24),
              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: SecondaryButton(
                  text: '¿Olvidaste tu contraseña?',
                  textColor: const Color(0xFFFC7171),
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
              const Spacer(),
              // Botón para crear usuario de prueba
              SecondaryButton(
                text: 'Crear usuario de prueba',
                textColor: const Color(0xFF10B981),
                onPressed: _isLoading ? null : _createTestUser,
              ),
              const SizedBox(height: 16),
              // Login button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                text: 'Iniciar',
                onPressed: _login,
              ),
              const SizedBox(height: 16),
              // Social login options
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButtonCustom(
                    icon: Icons.facebook,
                    backgroundColor: Colors.blue,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  IconButtonCustom(
                    icon: Icons.g_mobiledata,
                    backgroundColor: Colors.red,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  IconButtonCustom(
                    icon: Icons.apple,
                    backgroundColor: Colors.black,
                    onPressed: () {},
                  ),
                ],
              ),*/
              const SizedBox(height: 16),
              // Sign up link
              Center(
                child: SecondaryButton(
                  text: 'Crear una cuenta',
                  textColor: const Color(0xFF6366F1),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
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
