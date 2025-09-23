import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../setup/preserve_question_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                text: 'Iniciar',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreserveQuestionScreen(),
                    ),
                  );
                },
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
