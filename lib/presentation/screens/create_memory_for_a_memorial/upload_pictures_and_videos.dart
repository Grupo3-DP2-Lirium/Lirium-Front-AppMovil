import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/improve_picture.dart';
import 'package:image_picker/image_picker.dart';

class UploadPicturesAndVideos extends StatefulWidget {
  const UploadPicturesAndVideos({super.key});

  @override
  State<UploadPicturesAndVideos> createState() =>
      _UploadPicturesAndVideosState();
}

class _UploadPicturesAndVideosState extends State<UploadPicturesAndVideos> {

  void _goToImprovePicture(ImageSource source) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImprovePicture(source: source),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Subir fotos y videos",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Primera fil
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
                  label: "Desde Galaría",
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
