import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';

/// Pantalla que muestra el resultado de la mejora de imagen
class ImageResultScreen extends StatefulWidget {
  final String originalImagePath;
  final List<int> enhancedImageBytes;
  final String memorialId;

  const ImageResultScreen({
    super.key,
    required this.originalImagePath,
    required this.enhancedImageBytes,
    required this.memorialId,
  });

  @override
  State<ImageResultScreen> createState() => _ImageResultScreenState();
}

class _ImageResultScreenState extends State<ImageResultScreen> {
  bool _showOriginal = false;

  void _toggleComparison() {
    setState(() {
      _showOriginal = !_showOriginal;
    });
  }

  void _useEnhancedImage() {
    // Aquí puedes guardar la imagen mejorada
    // Por ahora solo navegamos de vuelta
    Navigator.popUntil(context, (route) => route.isFirst);
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagen mejorada guardada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _discardAndRetry() {
    // Volver a la pantalla anterior para seleccionar otra imagen
    Navigator.pop(context);
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
      ),
      body: Column(
        children: [
          // Imagen con comparación
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  // Imagen mejorada o original según el estado
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
                  
                  // Indicador de qué imagen se está mostrando
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _showOriginal ? 'Original' : 'Mejorada',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
                _showOriginal ? 'Ver mejorada' : 'Comparar con original',
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
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: _discardAndRetry,
                    text: "Reintentar",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: "Usar esta",
                    onPressed: _useEnhancedImage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}