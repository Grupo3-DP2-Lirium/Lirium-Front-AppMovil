import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'image_improvement_screen.dart';

/// Pantalla genérica para mejorar imágenes
/// Puede recibir una imagen ya seleccionada o seleccionarla desde cámara/galería
/// Devuelve la ruta de la imagen final (original o mejorada)
class ImprovePicture extends StatefulWidget {
  final ImageSource? source; // Opcional: si es null, debe venir imagePath
  final String? imagePath; // Opcional: imagen ya seleccionada
  
  const ImprovePicture({
    super.key, 
    this.source,
    this.imagePath,
  }) : assert(source != null || imagePath != null, 
         'Debe proporcionar source o imagePath');
  
  @override
  State<ImprovePicture> createState() => _ImprovePictureState();
}

class _ImprovePictureState extends State<ImprovePicture> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      // Ya tiene imagen, no necesita seleccionar
      print('📸 ImprovePicture iniciado con imagen: ${widget.imagePath}');
      _imagePath = widget.imagePath;
      _loading = false;
    } else {
      // Necesita seleccionar imagen
      print('📸 ImprovePicture iniciado, seleccionando imagen...');
      _pickImage();
    }
  }
  
  Future<void> _pickImage() async {
    if (widget.source == null) return;
    
    final XFile? image = await _picker.pickImage(source: widget.source!);
    if (mounted) {
      setState(() {
        _imagePath = image?.path;
        _loading = false;
      });
      print('📸 Imagen seleccionada: $_imagePath');
    }
  }
  
  void _selectNewImage() {
    if (widget.source == null) return;
    setState(() => _loading = true);
    _pickImage();
  }
  
  // ✅ CORREGIDO: Ahora espera el resultado y lo propaga hacia arriba
  Future<void> _startImageImprovement() async {
    if (_imagePath == null) return;
    
    print('🚀 Iniciando mejora de imagen...');
    
    final String? resultPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageImprovementScreen(
          imagePath: _imagePath!,
        ),
      ),
    );
    
    print('✅ ImprovePicture recibió resultado: $resultPath');
    
    // Si se recibió un resultado, cerrarse y devolverlo
    if (resultPath != null && mounted) {
      print('🔙 Propagando resultado hacia MemoryContainer');
      Navigator.pop(context, resultPath);
    } else {
      print('⚠️ No se recibió resultado, usuario canceló o hubo error');
    }
  }

  void _useOriginalImage() {
    if (_imagePath == null) return;
    print('🎯 Usuario eligió usar imagen original: $_imagePath');
    // Devolver la ruta de la imagen original
    Navigator.pop(context, _imagePath);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_imagePath == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text("No seleccionaste ninguna imagen"),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista previa"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              children: [
                PrimaryButton(
                  text: "Mejorar con IA",
                  onPressed: _startImageImprovement,
                  icon: Icons.auto_awesome,
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        onPressed: _useOriginalImage,
                        text: "Usar original",
                      ),
                    ),
                    if (widget.source != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _selectNewImage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(
                            widget.source == ImageSource.gallery
                                ? "Cambiar"
                                : "Repetir",
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}