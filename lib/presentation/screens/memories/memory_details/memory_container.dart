import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/file_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class MemoryContainer extends StatelessWidget {
  final Memory memory;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final double screenHeight;
  final ValueChanged<File?>? onFileChanged;
  final File? currentFile;

  const MemoryContainer({
    super.key,
    required this.memory,
    required this.titleController,
    required this.descriptionController,
    required this.screenHeight,
    this.onFileChanged,
    this.currentFile
  });

  @override
  Widget build(BuildContext context) {
    // Question & Answers
    if (memory.type == "question_answer") {
      return SizedBox(
        height: screenHeight,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                //label: "Pregunta",
                hintText: "Escribe la pregunta",
                controller: titleController,
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? "La pregunta es obligatoria"
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                //label: "Respuesta",
                hintText: "Escribe la respuesta",
                controller: descriptionController,
                maxLines: 3,
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? "La respuesta es obligatoria"
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    // Audio, Video o Image
    if (memory.type == "AUDIO" || memory.type == "VIDEO" ||
        memory.type == "IMAGE") {
      // Definir la altura dinámica según el tipo
      final double previewHeight =
      memory.type == "AUDIO" ? screenHeight * 0.10 : screenHeight * 0.40;
      final file = currentFile ?? (memory.files.isNotEmpty ? memory.files.first : null);
      final fileUrl = file?.url ?? "";
      final memoryTypeLower = memory.type.toLowerCase();

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vista previa
            Container(
              height: previewHeight,
              width: double.infinity,
              alignment: Alignment.center,
              child: FilePreview(
                type: memoryTypeLower,
                url: fileUrl,
                onEdit: () async {
                  final picked = await _pickFile(memoryTypeLower, context);
                  if (picked != null && onFileChanged != null) {
                    final tempFile = File(
                      id: "",
                      url: picked.path,
                      name: picked.name,
                      type: memoryTypeLower,
                      mimeType: _guessMimeType(picked.path),
                      size: (await picked.length()).toDouble(),
                      uploadedDate: DateTime.now(),
                      originalName: 'ARCHIVO',
                    );
                    onFileChanged!(tempFile);
                  }
                },
              ),
            ),

            // Fecha y ubicación debajo de la foto/video/audio
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey, width: 1), // línea abajo
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fecha en morado
                    if (memory.photoDate != null)
                      Text(
                        DateFormat('dd/MM/yy').format(memory.photoDate!),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    // Ubicación en un box
                    if (memory.location != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.inactive,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 18, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              memory.location!.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Formulario
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título (altura fija normal)
                  AppTextField(
                    hintText: "Escribe un título",
                    controller: titleController,
                    validator: (value) =>
                    (value == null || value.isEmpty)
                        ? "El título es obligatorio"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Descripción (ocupa el espacio sobrante)
                  AppTextField(
                    hintText: "Escribe una descripción",
                    maxLines: 10,
                    controller: descriptionController,
                    validator: (value) =>
                    (value == null || value.isEmpty)
                        ? "La descripción es obligatoria"
                        : null,
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    // Si no encaja en ninguno → default
    return const Text("⚠️ Tipo de memoria no soportado");
  }

  // Helpers
  /*Future<XFile?> _pickFile(String type, BuildContext context) async {
    final picker = ImagePicker();

    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galería"),
                onTap: () async {
                  final picked = await picker.pickImage(
                      source: ImageSource.gallery);
                  Navigator.pop(context, picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Cámara"),
                onTap: () async {
                  final picked = await picker.pickImage(
                      source: ImageSource.camera);
                  Navigator.pop(context, picked);
                },
              ),
            ],
          ),
        );
      },
    );
  }*/

  Future<XFile?> _pickFile(String type, BuildContext context) async {
    final picker = ImagePicker();

    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(type == "video" ? "Galería de videos" : "Galería de imágenes"),
                onTap: () async {
                  XFile? picked;
                  if (type == "video") {
                    picked = await picker.pickVideo(source: ImageSource.gallery);
                  } else {
                    picked = await picker.pickImage(source: ImageSource.gallery);
                  }
                  Navigator.pop(context, picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(type == "video" ? "Grabar video" : "Tomar foto"),
                onTap: () async {
                  XFile? picked;
                  if (type == "video") {
                    picked = await picker.pickVideo(source: ImageSource.camera);
                  } else {
                    picked = await picker.pickImage(source: ImageSource.camera);
                  }
                  Navigator.pop(context, picked);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _guessMimeType(String path) {
    if (path.endsWith(".jpg") || path.endsWith(".jpeg")) return "image/jpeg";
    if (path.endsWith(".png")) return "image/png";
    if (path.endsWith(".mp4")) return "video/mp4";
    if (path.endsWith(".mp3")) return "audio/mpeg";
    return "application/octet-stream";
  }

}