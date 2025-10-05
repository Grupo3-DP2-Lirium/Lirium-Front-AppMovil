import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart' as domain;
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/file_preview.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


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
  final picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  @override
  void initState() {
    super.initState();
    _localFiles = List.from(widget.memory.files);
    _initRecorder();
  }


  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Caso: carta
    if (_localFiles.isEmpty) {
      return _buildQA();
    }

    // Caso: + archivo multimedia (videos/imagenes)
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
        if (widget.memory.associatedQuestion != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppTextField(
              controller: TextEditingController(text: widget.memory.associatedQuestion),
              enabled: false,
              hintText: "Escribe la pregunta"
            ),
          ),

        // Título editable
        AppTextField(
          hintText: "Escribe la pregunta",
          controller: widget.titleController,
          validator: (v) => (v == null || v.isEmpty) ? "La pregunta es obligatoria" : null,
        ),
        const SizedBox(height: 16),

        // Descripción editable
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
    final multiple = _localFiles.length > 1; // ⚡ todos los archivos, no solo imágenes

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
        key: ValueKey(url), // forzar reconstrucción
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
        if (widget.memory.associatedQuestion != null &&
            widget.memory.associatedQuestion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppTextField(
              controller: TextEditingController(text: widget.memory.associatedQuestion),
              enabled: false,
              hintText: 'Pregunta Default',
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppTextField(
              hintText: "Escribe un título",
              controller: widget.titleController,
              validator: (v) => (v == null || v.isEmpty) ? "El título es obligatorio" : null,
            ),
          ),
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

    final file = File(picked.path);
    final exists = await file.exists();
    if (!exists) {
      //print("Archivo todavía no existe: ${picked.path}");
      return;
    }

    final newFile = domain.File(
      id: "",
      url: picked.path,
      name: picked.name,
      type: type,
      mimeType: _guessMimeType(picked.path),
      size: (await picked.length()).toDouble(),
      uploadedDate: DateTime.now(),
      originalName: picked.name,
    );

    setState(() {
      if (index != null && index < _localFiles.length) {
        // Actualizar archivo existente
        _localFiles[index] = newFile;
        widget.onFileChanged?.call("update", index, newFile);
      } else if (type == "audio") {
        // Si ya hay un audio, reemplazarlo
        final existingIndex = _localFiles.indexWhere((f) => f.type == "audio");
        if (existingIndex != -1) {
          _localFiles[existingIndex] = newFile;
          widget.onFileChanged?.call("update", existingIndex, newFile);
        } else {
          // No hay audio previo, agregar
          _localFiles.add(newFile);
          widget.onFileChanged?.call("add", null, newFile);
        }
      } else {
        // Otros tipos (imagen/video) se agregan
        _localFiles.add(newFile);
        widget.onFileChanged?.call("add", null, newFile);
      }
    });

  }

  // ------------------- Selector de imagen/video/audio -------------------
  Future<XFile?> _pickFile(String type, BuildContext context) async {
    final picker = ImagePicker();

    if (type == "audio") {
      final hasPermission = await _checkMicrophonePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de micrófono denegado")),
        );
        return null;
      }
      XFile? recordedFile;
      bool isRecording = false;
      bool isPlaying = false;
      Duration recordingDuration = Duration.zero;
      Timer? _timer;
      final FlutterSoundPlayer player = FlutterSoundPlayer();
      await player.openPlayer();

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecording ? "Grabando..." : "Listo para grabar",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Fila horizontal: Grabar | Reproducir (oculto si graba) | Tiempo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Grabar
                      ElevatedButton.icon(
                        icon: Icon(isRecording ? Icons.stop : Icons.mic),
                        label: Text(isRecording ? "Detener" : "Grabar"),
                        onPressed: () async {
                          final tempDir = Directory.systemTemp;
                          final filePath =
                              '${tempDir.path}/recorded_${DateTime.now().millisecondsSinceEpoch}.aac';

                          if (!isRecording) {
                            recordedFile = XFile(filePath);
                            recordingDuration = Duration.zero;

                            await _recorder.startRecorder(
                              toFile: filePath,
                              codec: Codec.aacADTS,
                            );

                            _timer = Timer.periodic(const Duration(seconds: 1), (_) {
                              setModalState(() {
                                recordingDuration += const Duration(seconds: 1);
                              });
                            });

                            setModalState(() => isRecording = true);
                          } else {
                            await _recorder.stopRecorder();
                            _timer?.cancel();
                            _timer = null;
                            setModalState(() => isRecording = false);
                          }
                        },
                      ),

                      const SizedBox(width: 16),

                      // Botón Reproducir (solo si hay audio y no se está grabando)
                      if (recordedFile != null && !isRecording)
                        ElevatedButton.icon(
                          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                          label: Text(isPlaying ? "Detener" : "Reproducir"),
                          onPressed: () async {
                            if (!isPlaying) {
                              await player.startPlayer(
                                fromURI: recordedFile!.path,
                                codec: Codec.aacADTS,
                                whenFinished: () {
                                  setModalState(() => isPlaying = false);
                                },
                              );
                              setModalState(() => isPlaying = true);
                            } else {
                              await player.stopPlayer();
                              setModalState(() => isPlaying = false);
                            }
                          },
                        ),

                      const SizedBox(width: 16),

                      // Tiempo
                      Text(
                        "${recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:"
                            "${recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Línea divisoria
                  Divider(
                    thickness: 1.5,
                    color: Colors.grey[400],
                    indent: 20,
                    endIndent: 20,
                  ),

                  const SizedBox(height: 16),

                  // Botones Usar audio / Desechar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Usar audio"),
                        onPressed: () => Navigator.pop(context, recordedFile),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Desechar"),
                        onPressed: () {
                          recordedFile = null;
                          Navigator.pop(context, null);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await player.closePlayer();
      return recordedFile;
    }
      // --- Video / Imagen ---
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