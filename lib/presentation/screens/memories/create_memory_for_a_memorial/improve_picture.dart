import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'image_improvement_screen.dart';

class ImprovePicture extends StatefulWidget {
  final ImageSource source;
  final String memorialId;
  
  const ImprovePicture({super.key, required this.source, required this.memorialId});
  
  @override
  State<ImprovePicture> createState() => _ImprovePictureState();
}

class _ImprovePictureState extends State<ImprovePicture> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _pickImage();
  }
  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: widget.source);
    if (mounted) {
      setState(() {
        _image = image;
        _loading = false;
      });
    }
  }
  
  void _selectNewImage() {
    setState(() => _loading = true);
    _pickImage();
  }
  
  void _startImageImprovement() {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageImprovementScreen(
            imagePath: _image!.path, 
            memorialId: widget.memorialId
          ),
        ),
      );
    }
  }

  Future<void> _useOriginalImage() async {
    if (_image == null) return;
    
    try {
      // Mostrar loading mientras se guarda
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // TODO: Aquí debes llamar a tu servicio real para guardar la imagen
      // Ejemplo (ajusta según tu lógica de negocio):
      // 
      // final memoryService = MemoryService();
      // final request = MemoryCreateRequest(
      //   memorialId: widget.memorialId,
      //   title: "Nueva foto",
      //   type: MemoryType.PHOTO,
      //   // ... otros campos
      // );
      // 
      // await memoryService.createMemory(
      //   request: request,
      //   files: [File(_image!.path)],
      // );
      
      // Por ahora simulamos el guardado
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // Cerrar loading
        Navigator.pop(context);
        
        // Volver al inicio
        Navigator.popUntil(context, (route) => route.isFirst);
        
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen original guardada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Cerrar loading
        Navigator.pop(context);
        
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_image == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("No seleccionaste ninguna imagen")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista previa"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Imagen con padding controlado
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          
          // Botones en dos filas
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              children: [
                // Primera fila: Mejorar (destacado)
                PrimaryButton(
                  text: "Mejorar con IA",
                  onPressed: _startImageImprovement,
                  icon: Icons.auto_awesome,
                ),
                
                const SizedBox(height: 12),
                
                // Segunda fila: Guardar sin mejorar y Cambiar
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        onPressed: _useOriginalImage,
                        text: "Guardar así",
                      ),
                    ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}