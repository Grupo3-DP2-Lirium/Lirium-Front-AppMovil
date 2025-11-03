import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/password_recovery_service.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordRecoveryService = PasswordRecoveryService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Por favor ingresa tu correo electrónico');
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Por favor ingresa un correo válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _passwordRecoveryService.requestPasswordReset(email);

      if (!mounted) return;

      // Navegar a la pantalla de verificación de código
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCodeScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF20242B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Título
              const AppTitle(title: 'Olvidaste tu contraseña'),
              const SizedBox(height: 16),
              // Subtítulo
              Text(
                'Enviaremos un correo de verificación al correo electrónico que registraste al crear tu cuenta.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Campo de email
              AppTextField(
                hintText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: !_isLoading,
              ),
              const Spacer(),
              // Botón Siguiente
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Siguiente',
                      onPressed: _sendCode,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
