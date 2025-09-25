import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../setup/preserve_question_screen.dart';
import '../../../providers/auth_providers.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Maneja el proceso de login
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
      email: email,
      password: password,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PreserveQuestionScreen(),
        ),
      );
    }
  }

  /// Muestra un error en un SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Mostrar errores automáticamente
    ref.listen<bool>(authProvider.select((state) => state.error != null),
        (_, hasError) {
      if (hasError && authState.error != null) {
        _showError(authState.error!);
        ref.read(authProvider.notifier).clearError();
      }
    });
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
                  textColor: const Color(0xFF6366F1),
                  onPressed: () {},
                ),
              ),
              const Spacer(),
              // Login button
              PrimaryButton(
                text: authState.isLoading ? 'Iniciando...' : 'Iniciar',
                onPressed: authState.isLoading ? null : _handleLogin,
              ),
              const SizedBox(height: 16),
              // Social login options
              Row(
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
              ),
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
