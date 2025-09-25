import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/components.dart';
import 'package:image_picker/image_picker.dart'; // 👈 importante

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCountryCode = '+1';
  File? _imageController;

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
          'Crea',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                    setState(() {
                      _imageController = file; // <-- aquí guardas la imagen
                    });
                  },
                ),
              ),
            const SizedBox(height: 40),
            // Form fields
            AppTextField(
              hintText: 'Fernanda López',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AppTextField(
              hintText: 'Nombre de usuario',
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre de usuario';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AppTextField(
              hintText: 'Fecha de nacimiento',
              controller: _birthdateController,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.grey),
                onPressed: () => _selectDate(context),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona tu fecha de nacimiento';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AppTextField(
              hintText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Por favor ingresa un email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Phone number field with country code
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Text('🇺🇸', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedCountryCode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: '+1', child: Text('+1')),
                          DropdownMenuItem(value: '+52', child: Text('+52')),
                          DropdownMenuItem(value: '+34', child: Text('+34')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    hintText: 'Número de teléfono',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu número de teléfono';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Continue button
            PrimaryButton(
              text: 'Continuar',
              onPressed: () {
                // Validate and navigate to next screen
                _handleContinue();
              },
            ),
            const SizedBox(height: 20),
            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes cuenta? ',
                  style: TextStyle(color: Colors.grey),
                ),
                SecondaryButton(
                  text: 'Inicia sesión',
                  textColor: const Color(0xFF6366F1),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _handleContinue() {
    // Validate all fields
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to next screen (could be email verification, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    // For now, navigate back to login
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
