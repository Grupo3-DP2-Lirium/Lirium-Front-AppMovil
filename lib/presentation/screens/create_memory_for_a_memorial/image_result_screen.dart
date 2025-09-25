import 'dart:io';
import 'package:flutter/material.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/forms/app_text_field.dart';
import 'memory_success_screen.dart';

/// Pantalla que muestra la imagen mejorada con campo de título
class ImageResultScreen extends StatefulWidget {
  final String imagePath;

  const ImageResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageResultScreen> createState() => _ImageResultScreenState();
}

class _ImageResultScreenState extends State<ImageResultScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Por favor ingresa un título');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Aquí iría la lógica para guardar la memoria
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(seconds: 1));
        _navigateToSuccess();
      }
    } catch (e) {
      _showError('Error al guardar la memoria');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Memoria guardada exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MemorySuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Imagen Mejorada'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Imagen mejorada
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Campo de título y botón
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _titleController,
                    hintText: 'Escribe un título para tu memoria...',
                    prefixIcon: Icons.title_outlined,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: _isSaving ? 'Guardando...' : 'Guardar Memoria',
                    onPressed: _isSaving ? null : _saveMemory,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}