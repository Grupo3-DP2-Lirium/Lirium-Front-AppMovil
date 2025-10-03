import 'package:flutter/material.dart';
import 'memory_success_screen.dart';
import '../../../data/services/memory_service.dart';
import '../../../data/models/memory_create_request.dart';
import '../../../domain/enums/memory_origin_type.dart';

/// Pantalla para escribir una carta personal
class WriteLetterScreen extends StatefulWidget {
  final String memorialId;

  const WriteLetterScreen({
    super.key,
    required this.memorialId,
  });

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final TextEditingController _letterController = TextEditingController();
  final MemoryService _memoryService = MemoryService();
  bool _isSaving = false;

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  Future<void> _saveLetter() async {
    if (_letterController.text.trim().isEmpty) {
      _showError('Por favor escribe tu mensaje');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final request = MemoryCreateRequest(
        memorialId: widget.memorialId,
        type: MemoryOriginType.spontaneous,
        title: 'Carta personal',
        description: _letterController.text.trim(),
        photoDate: DateTime.now(),
      );

      await _memoryService.createMemory(
        request: request,
        files: null, // Sin archivos para cartas
      );

      if (mounted) {
        _showSuccess();
        await Future.delayed(const Duration(seconds: 1));
        _navigateToSuccess();
      }
    } catch (e) {
      _showError('Error al guardar la carta: $e');
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
        content: Text('¡Carta guardada exitosamente!'),
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
        title: const Text('Escribir Carta'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Pregunta principal
              const Text(
                '¿Qué te gustaría decirle?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Campo de texto con botón integrado
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _letterController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu mensaje aquí...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    // Botón Guardar en esquina inferior derecha
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveLetter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _isSaving ? 'Guardando...' : 'Guardar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}