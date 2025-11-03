import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/password_recovery_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:flutter_frontend/presentation/components/forms/code_input_field.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _passwordRecoveryService = PasswordRecoveryService();
  String _code = '';
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 60; // Segundos antes de permitir reenviar
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_code.length != 6) {
      _showMessage('Por favor ingresa el código completo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resetToken = await _passwordRecoveryService.verifyCode(
        widget.email,
        _code,
      );

      if (!mounted) return;

      // Navegar a la pantalla de restablecer contraseña
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            resetToken: resetToken,
          ),
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

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      await _passwordRecoveryService.requestPasswordReset(widget.email);
      if (!mounted) return;
      _showMessage('Código reenviado exitosamente');
      _startCountdown();
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
              const Text(
                'Ingresa los 6 dígitos del código que enviamos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF20242B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // Subtítulo
              Text(
                'Revisa en tu email el código de verificación',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Campo de código (6 cajas)
              CodeInputField(
                onCompleted: (code) {
                  setState(() => _code = code);
                },
                onChanged: (code) {
                  setState(() => _code = code);
                },
              ),
              const SizedBox(height: 24),
              // Botón de reenviar código
              Center(
                child: _canResend
                    ? SecondaryButton(
                        text: 'Reenviar código',
                        textColor: const Color(0xFFFC7171),
                        onPressed: _isLoading ? null : _resendCode,
                      )
                    : Text(
                        'Reenviar código en 0:${_countdown.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              // Mensaje sobre spam
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Si no recibiste el email en tu bandeja de entrada recomendamos revisar Spam.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Botón Enviar
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Enviar',
                      onPressed: _code.length == 6 ? _verifyCode : null,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
