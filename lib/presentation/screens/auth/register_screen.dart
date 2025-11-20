import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_field.dart';
import '../../components/components.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/register_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _secondLastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final AuthService _authService = AuthService();

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
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile picture section
              Center(
                child: ProfileAvatar(
                  radius: 60,
                  showCameraIcon: true,
                  placeholderIcon: Icons.image_outlined,
                  onImageChanged: (file) {
                    // Imagen seleccionada - por implementar
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Nombre con CustomTextField
              CustomTextField(
                label: 'Nombre',
                hintText: 'Tu nombre',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  if (value.length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Primer apellido
              CustomTextField(
                label: 'Primer apellido',
                hintText: 'Tu primer apellido',
                controller: _lastNameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu primer apellido';
                  }
                  if (value.length < 2) {
                    return 'El apellido debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Segundo apellido (opcional)
              CustomTextField(
                label: 'Segundo apellido (opcional)',
                hintText: 'Tu segundo apellido',
                controller: _secondLastNameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'El segundo apellido debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email
              CustomTextField(
                label: 'Correo electrónico',
                hintText: 'correo@ejemplo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Por favor ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              CustomTextField(
                label: 'Contraseña',
                hintText: 'Mínimo 8 caracteres',
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
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
                  final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                  final hasDigit = RegExp(r'\d').hasMatch(value);
                  final hasSpecialChar = RegExp(r'[@$!%*?&#_]').hasMatch(value);

                  if (!hasLowercase || !hasUppercase || !hasDigit || !hasSpecialChar) {
                    return 'Debe contener: 1 minúscula, 1 mayúscula, 1 número y 1 carácter especial';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password
              CustomTextField(
                label: 'Confirmar contraseña',
                hintText: 'Repite tu contraseña',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Register button
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : PrimaryButton(
                text: 'Crear Cuenta',
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 20),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
          SecondaryButton(
              text: 'Inicia sesión',
              textColor: AppColors.primary,
              isFullWidth: false,
              onPressed: () {
                Navigator.pop(context);
              },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registerRequest = RegisterRequest(
        firstName: _nameController.text.trim(),
        firstLastName: _lastNameController.text.trim(),
        secondLastName: _secondLastNameController.text.trim().isEmpty
            ? null
            : _secondLastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userResponse = await _authService.register(registerRequest);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Bienvenido ${userResponse['firstName']}! Cuenta creada exitosamente',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        String errorMessage = 'Error al crear la cuenta';

        if (e.toString().contains('Email already exists') ||
            e.toString().contains('Email ya está registrado')) {
          errorMessage =
          'Este email ya está registrado. Usa otro email o inicia sesión.';
        } else if (e.toString().contains('Error de validación')) {
          errorMessage =
          'Por favor verifica que todos los campos estén correctos';
        } else if (e.toString().contains('Connection refused') ||
            e.toString().contains('Network')) {
          errorMessage =
          'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}