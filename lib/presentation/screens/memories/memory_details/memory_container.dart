import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart' as domain;
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/file_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MemoryContainer extends StatefulWidget {
  final Memory memory;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final double screenHeight;
  final void Function(String action, [int? index, domain.File? file])? onFileChanged;

  const MemoryContainer({
    super.key,
    required this.memory,
    required this.titleController,
    required this.descriptionController,
    required this.screenHeight,
    this.onFileChanged,
  });

  @override
  State<MemoryContainer> createState() => _MemoryContainerState();
}

class _MemoryContainerState extends State<MemoryContainer> {
  late List<domain.File> _localFiles; // copia editable

  @override
  void initState() {
    super.initState();
    _localFiles = List.from(widget.memory.files);
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;

    // Caso: pregunta y respuesta
    if (_localFiles.isEmpty) {
      return _buildQA();
    }

    // Caso: archivo multimedia
    if (_localFiles.isNotEmpty &&
        ["image", "video", "audio"].contains(_localFiles.first.type)) {
      final file = _localFiles.first;
      final fileType = file.type;
      final fileUrl = file.url;
      final previewHeight =
      fileType == "audio" ? widget.screenHeight * 0.10 : widget.screenHeight * 0.40;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(fileType, fileUrl, previewHeight, context),
            _buildMetaData(),
            _buildForm(),
          ],
        ),
      );
    }

    return const Text("⚠️ Tipo de memoria no soportado");
  }

  // ------------------- Pregunta / Respuesta -------------------
  Widget _buildQA() => SingleChildScrollView(
    child: Column(
      children: [
        AppTextField(
          hintText: "Escribe la pregunta",
          controller: widget.titleController,
          validator: (v) => (v == null || v.isEmpty) ? "La pregunta es obligatoria" : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          hintText: "Escribe la respuesta",
          controller: widget.descriptionController,
          maxLines: 3,
          validator: (v) => (v == null || v.isEmpty) ? "La respuesta es obligatoria" : null,
        ),
      ],
    ),
  );

  // ------------------- Vista previa -------------------
  Widget _buildPreview(String type, String url, double height, BuildContext context) {
    final multiple = _localFiles.length > 1 && _localFiles.first.type == "image";

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: multiple
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageView.builder(
          itemCount: _localFiles.length,
          itemBuilder: (context, index) {
            final file = _localFiles[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                FilePreview(
                  key: ValueKey(file.url),
                  type: file.type,
                  url: file.url,
                  onEdit: () => _editFile(context, file.type, index: index),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${index + 1}/${_localFiles.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      )
          : FilePreview(
        type: type,
        url: url,
        onEdit: () => _editFile(context, type),
      ),
    );
  }

  // ------------------- Metadata -------------------
  Widget _buildMetaData() => Container(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.memory.photoDate != null)
            Text(
              DateFormat('dd/MM/yy').format(widget.memory.photoDate!),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (widget.memory.location != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.inactive,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Text(
                    widget.memory.location!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  // ------------------- Formulario -------------------
  Widget _buildForm() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        AppTextField(
          hintText: "Escribe un título",
          controller: widget.titleController,
          validator: (v) => (v == null || v.isEmpty) ? "El título es obligatorio" : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          hintText: "Escribe una descripción",
          maxLines: 10,
          controller: widget.descriptionController,
          validator: (v) =>
          (v == null || v.isEmpty) ? "La descripción es obligatoria" : null,
        ),
      ],
    ),
  );

  // ------------------- Editar archivo -------------------
  Future<void> _editFile(BuildContext context, String type, {int? index}) async {
    final picked = await _pickFile(type, context);
    if (picked == null) return;

    final newFile = domain.File(
      id: "",
      url: picked.path, // temporal local (ImagePreview lo soporta)
      name: picked.name,
      type: type,
      mimeType: _guessMimeType(picked.path),
      size: (await picked.length()).toDouble(),
      uploadedDate: DateTime.now(),
      originalName: picked.name,
    );

    // ⚡ Actualizamos la lista local y llamamos a onFileChanged
    setState(() {
      if (index != null) {
        if (index < _localFiles.length) {
          _localFiles[index] = newFile;
          widget.onFileChanged?.call("update", index, newFile);
        } else {
          // Si por alguna razón el índice es inválido, agregamos
          _localFiles.add(newFile);
          widget.onFileChanged?.call("add", null, newFile);
        }
      } else {
        _localFiles.add(newFile);
        widget.onFileChanged?.call("add", null, newFile);
      }
    });
  }

  // ------------------- Selector de imagen/video -------------------
  Future<XFile?> _pickFile(String type, BuildContext context) async {
    final picker = ImagePicker();
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(type == "video" ? "Galería de videos" : "Galería de imágenes"),
              onTap: () async {
                final picked = type == "video"
                    ? await picker.pickVideo(source: ImageSource.gallery)
                    : await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(type == "video" ? "Grabar video" : "Tomar foto"),
              onTap: () async {
                final picked = type == "video"
                    ? await picker.pickVideo(source: ImageSource.camera)
                    : await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, picked);
              },
            ),
          ],
        ),
      ),
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