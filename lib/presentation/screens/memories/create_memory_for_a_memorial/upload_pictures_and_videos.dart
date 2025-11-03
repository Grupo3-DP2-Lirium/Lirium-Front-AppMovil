import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/improve_picture.dart';
import 'package:image_picker/image_picker.dart';

class UploadPicturesAndVideos extends StatefulWidget {
  final String memorialId;
  
  const UploadPicturesAndVideos({super.key, required this.memorialId});

  @override
  State<UploadPicturesAndVideos> createState() =>
      _UploadPicturesAndVideosState();
}

class _UploadPicturesAndVideosState extends State<UploadPicturesAndVideos> {

  // ========== MODIFICADO: Ahora espera el resultado y hace algo con él ==========
  Future<void> _goToImprovePicture(ImageSource source) async {
    // Navega a ImprovePicture (ya no necesita memorialId)
    final String? imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ImprovePicture(source: source), // SIN memorialId
      ),
    );
    
    // Si el usuario seleccionó/mejoró una imagen
    if (imagePath != null && mounted) {
      // Aquí decides qué hacer con la imagen:
      // Opción 1: Mostrar un snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagen seleccionada: ${imagePath.split('/').last}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Opción 2: Guardarla directamente
      // await _uploadImageToMemorial(imagePath);
      
      // Opción 3: Volver a la pantalla anterior con el resultado
      // Navigator.pop(context, imagePath);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Subir fotos y videos",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Primera fila
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RectangleButton(
                  icon: Icons.photo_camera,
                  label: "Desde cámara",
                  size: 120,
                  onTap: () => _goToImprovePicture(ImageSource.camera),
                ),
                const SizedBox(width: 24),
                RectangleButton(
                  icon: Icons.attach_file,
                  label: "Desde Galería",
                  size: 120,
                  onTap: () => _goToImprovePicture(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}