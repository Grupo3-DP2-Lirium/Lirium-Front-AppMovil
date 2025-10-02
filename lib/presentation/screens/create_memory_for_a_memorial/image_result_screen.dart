import 'dart:io';
import 'package:flutter/material.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/forms/app_text_field.dart';
import 'memory_success_screen.dart';
import '../../../data/services/memory_service.dart';
import '../../../data/models/memory_create_request.dart';
import '../../../domain/enums/memory_origin_type.dart';

/// Pantalla que muestra la imagen mejorada con campo de título
class ImageResultScreen extends StatefulWidget {
  final String imagePath;
  final String memorialId;

  const ImageResultScreen({
    super.key,
    required this.imagePath,
    required this.memorialId,
  });

  @override
  State<ImageResultScreen> createState() => _ImageResultScreenState();
}

class _ImageResultScreenState extends State<ImageResultScreen> {
  final TextEditingController _titleController = TextEditingController();
  final MemoryService _memoryService = MemoryService();
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
      final request = MemoryCreateRequest(
        memorialId: widget.memorialId,
        type: MemoryOriginType.spontaneous,
        title: _titleController.text.trim(),
        photoDate: DateTime.now(),
      );

      final imageFile = File(widget.imagePath);
      print('DEBUG: Image file exists: ${await imageFile.exists()}');
      print('DEBUG: Image file path: ${widget.imagePath}');
      print('DEBUG: Image file size: ${await imageFile.length()} bytes');
      
      await _memoryService.createMemory(
        request: request,
        files: [imageFile],
      );

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(seconds: 1));
        _navigateToSuccess();
      }
    } catch (e) {
      _showError('Error al guardar la memoria: $e');
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