import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:path_provider/path_provider.dart';

/// Pantalla genérica que muestra el resultado de la mejora de imagen
/// Devuelve la ruta de la imagen seleccionada (mejorada o original según toggle)
class ImageResultScreen extends StatefulWidget {
  final String originalImagePath;
  final List<int> enhancedImageBytes;

  const ImageResultScreen({
    super.key,
    required this.originalImagePath,
    required this.enhancedImageBytes,
  });

  @override
  State<ImageResultScreen> createState() => _ImageResultScreenState();
}

class _ImageResultScreenState extends State<ImageResultScreen> {
  bool _showOriginal = false; // Por defecto muestra la mejorada

  void _toggleComparison() {
    setState(() {
      _showOriginal = !_showOriginal;
    });
  }

  Future<void> _useSelectedImage() async {
    print('🎯 Usuario eligió usar: ${_showOriginal ? "original" : "mejorada"}');
    
    try {
      String selectedImagePath;
      
      if (_showOriginal) {
        // Usar imagen original
        selectedImagePath = widget.originalImagePath;
        print('📸 Usando imagen original: $selectedImagePath');
      } else {
        // Guardar imagen mejorada en archivo temporal
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFile = File('${tempDir.path}/enhanced_$timestamp.jpg');
        await tempFile.writeAsBytes(widget.enhancedImageBytes);
        selectedImagePath = tempFile.path;
        print('✨ Imagen mejorada guardada en: $selectedImagePath');
      }
      
      if (mounted) {
        Navigator.pop(context, selectedImagePath);
      }
    } catch (e) {
      print('❌ Error al procesar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Resultado'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Cancelar (sin resultado)
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showOriginal
                          ? Image.file(
                              File(widget.originalImagePath),
                              key: const ValueKey('original'),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.memory(
                              Uint8List.fromList(widget.enhancedImageBytes),
                              key: const ValueKey('enhanced'),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                  
                  // Badge indicador
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _showOriginal ? Colors.grey[700] : Colors.green[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showOriginal ? Icons.image : Icons.auto_awesome,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showOriginal ? 'Original' : 'Mejorada',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botón de comparación
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: _toggleComparison,
              icon: Icon(
                _showOriginal ? Icons.auto_awesome : Icons.compare,
                size: 20,
              ),
              label: Text(
                _showOriginal ? 'Ver imagen mejorada' : 'Comparar con original',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón principal - usa la imagen que esté visible
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: PrimaryButton(
              text: _showOriginal ? "Usar imagen original" : "Usar imagen mejorada",
              onPressed: _useSelectedImage,
            ),
          ),
        ],
      ),
    );
  }
}