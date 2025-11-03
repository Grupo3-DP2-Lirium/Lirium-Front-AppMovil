import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/password_recovery_service.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordRecoveryService = PasswordRecoveryService();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Muy corta';
    if (password.length < 9) return 'Débil';
    return 'Segura';
  }

  Color _getPasswordStrengthColor(String password) {
    if (password.isEmpty) return Colors.grey;
    if (password.length < 6) return const Color(0xFFEF4444);
    if (password.length < 9) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }

    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _passwordRecoveryService.resetPassword(
        widget.resetToken,
        password,
      );

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Contraseña actualizada exitosamente!'),
          backgroundColor: Color(0xFF22C55E),
          duration: Duration(seconds: 2),
        ),
      );

      // Esperar un momento y volver al login
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Volver al login con el email pre-rellenado
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(initialEmail: widget.email),
        ),
        (route) => false, // Remover todas las rutas anteriores
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
    final password = _passwordController.text;
    final strength = _getPasswordStrength(password);
    final strengthColor = _getPasswordStrengthColor(password);

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
              const Text(
                'Contraseñas y seguridad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF20242B),
                ),
              ),
              const SizedBox(height: 16),
              // Subtítulo
              Text(
                'Crea una nueva contraseña de al menos 6 caracteres',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Campo nueva contraseña
              PasswordField(
                controller: _passwordController,
                hintText: 'Escribe tu nueva contraseña',
                onChanged: (value) {
                  setState(() {}); // Actualizar indicador de fortaleza
                },
              ),
              const SizedBox(height: 8),
              // Indicador de fortaleza
              if (password.isNotEmpty)
                Row(
                  children: [
                    Container(
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: strengthColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      strength,
                      style: TextStyle(
                        fontSize: 12,
                        color: strengthColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Campo confirmar contraseña
              PasswordField(
                controller: _confirmPasswordController,
                hintText: 'Confirma tu nueva contraseña',
              ),
              const Spacer(),
              // Botón Guardar
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Guardar contraseña',
                      onPressed: _resetPassword,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
