import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/select_category.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/upload_pictures_and_videos.dart';

class CreateMemorySelectType extends StatefulWidget {
  final String memorialId; // Necesitas este ID para asociar los recuerdos al memorial

  const CreateMemorySelectType({super.key, required this.memorialId});

  @override
  State<CreateMemorySelectType> createState() => _CreateMemorySelectTypeState();
}

class _CreateMemorySelectTypeState extends State<CreateMemorySelectType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "¿Qué vas a hacer hoy?",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Primera fila con botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RectangleButton(
                  icon: Icons.photo_camera,
                  label: "Subir fotos y videos",
                  size: 120,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPicturesAndVideos(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                RectangleButton(
                  icon: Icons.edit,
                  label: "Escribir una carta",
                  size: 120,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateMemorySelectType(memorialId: widget.memorialId),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Segunda fila
            Text(
              "¿Qué vas a hacer hoy?",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RectangleButton(
                  icon: Icons.monitor_heart,
                  label: "Responder preguntas",
                  size: 120,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectCategory(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
