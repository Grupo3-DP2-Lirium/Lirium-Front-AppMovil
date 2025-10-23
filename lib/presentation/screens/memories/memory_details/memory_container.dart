import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart' as domain;
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/fields_widget.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/files_preview_widget.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';

class MemoryContainer extends StatefulWidget {
  final Memory memory;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController mesController;
  final TextEditingController ahoController;
  final TextEditingController locationController;
  final double screenHeight;
  final bool edit;
  final List<domain.File>? existingFiles;
  final void Function(String action, [int? index, domain.File? file])? onFileChanged;

  const MemoryContainer({
    super.key,
    required this.memory,
    required this.titleController,
    required this.descriptionController,
    required this.mesController,
    required this.ahoController,
    required this.locationController,
    required this.screenHeight,
    this.edit = false,
    this.onFileChanged,
    this.existingFiles,
  });

  @override
  State<MemoryContainer> createState() => _MemoryContainerState();
}

class _MemoryContainerState extends State<MemoryContainer> with AutomaticKeepAliveClientMixin {
  late List<domain.File> _localFiles; // Editable list of files for the memory
  final picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  int _currentFileIndex = 0;
  final Map<Key, VideoPlayerController> _videoControllers = {}; // Mapping of video controllers for video files
  bool _isEditing = false; // Tracks widget mode
  late final bool _hadOriginalFiles;

  // Method to switch edit mode without recreating the widget
  void setEditMode(bool value) {
    if (!mounted) return;
    setState(() {
      _isEditing = value;
    });
  }

  // Restores the original files and resets any changes made
  void restoreOriginalFiles(List<domain.File> originalFiles) {
    if (!mounted) return;
    setState(() {
      _localFiles = List.from(originalFiles); // Reset local files to the original state
      _currentFileIndex = 0;
    });
  }

  @override
  bool get wantKeepAlive => true; // Keeps widget alive when switching tabs

  // Initialize the audio recorder
  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  // Check and request microphone permissions if not granted
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
    _localFiles = List.from(widget.existingFiles ?? []); // Initialize with existing files or empty list
    _isEditing = widget.edit;
    _initRecorder(); // Initialize audio recorder
    _hadOriginalFiles = (widget.existingFiles?.isNotEmpty ?? false);
  }

  // Detect changes in existing files passed
  @override
  void didUpdateWidget(covariant MemoryContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Get URLs of old and new files to check for changes
    final oldUrls = (oldWidget.existingFiles ?? []).map((f) => f.url).toList();
    final newUrls = (widget.existingFiles ?? []).map((f) => f.url).toList();

    // Only update if the content of the parent has changed (added/replaced files)
    if (oldUrls.join(',') != newUrls.join(',')) {
      // Avoid resetting the file index if files already exist
      setState(() {
        _localFiles = List.from(widget.existingFiles ?? []);
        // Ensure current file index stays within the valid range
        if (_currentFileIndex >= _localFiles.length) {
          _currentFileIndex = _localFiles.isEmpty ? 0 : _localFiles.length - 1;
        }
      });
    }
  }

  // Dispose the recorder when the widget is disposed to clean up resources
  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Caso: hay archivos
    if (_localFiles.isNotEmpty) {
      final file = _localFiles.first;
      final fileType = file.type;
      final previewHeight =
      fileType == "audio" ? widget.screenHeight * 0.10 : widget.screenHeight * 0.40;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PreviewWidget(
              localFiles: _localFiles,
              currentFileIndex: _currentFileIndex,
              isEditing: _isEditing,
              deleteFile: _deleteFile,
              editFile: _editFile,
              showAddOptions: _showAddOptions,
              height: previewHeight,
              videoControllers: _videoControllers,
            ),
            MemoryFormulario(
              memory: widget.memory,
              isEditing: _isEditing,
              titleController: widget.titleController,
              descriptionController: widget.descriptionController,
              mesController: widget.mesController,
              ahoController: widget.ahoController,
              locationController: widget.locationController,
            ),
          ],
        ),
      );
    }

    // Caso: no hay archivos
    if (_localFiles.isEmpty && _hadOriginalFiles) {
      // Mostrar PreviewWidget vacío + botón añadir
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PreviewWidget(
              localFiles: _localFiles, // lista vacía
              currentFileIndex: _currentFileIndex,
              isEditing: _isEditing,
              deleteFile: _deleteFile,
              editFile: _editFile,
              showAddOptions: _showAddOptions,
              height: widget.screenHeight * 0.40,
              videoControllers: _videoControllers,
            ),
            MemoryFormulario(
              memory: widget.memory,
              isEditing: _isEditing,
              titleController: widget.titleController,
              descriptionController: widget.descriptionController,
              mesController: widget.mesController,
              ahoController: widget.ahoController,
              locationController: widget.locationController,
            ),
          ],
        ),
      );
    }

    // Memorias que nunca tuvieron archivos
    return _buildQA();
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
              hintText: "Escribe la pregunta",
            ),
          ),

        // Título editable
        AppTextField(
          hintText: "Escribe la pregunta",
          controller: widget.titleController,
          enabled: _isEditing,
          validator: (v) => (v == null || v.isEmpty) ? "La pregunta es obligatoria" : null,
        ),
        const SizedBox(height: 16),

        // Descripción editable
        AppTextField(
          hintText: "Escribe la respuesta",
          controller: widget.descriptionController,
          enabled: _isEditing,
          maxLines: 20,
          validator: (v) => (v == null || v.isEmpty) ? "La respuesta es obligatoria" : null,
        ),
      ],
    ),
  );

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Añadir imagen"),
                onTap: () {
                  Navigator.pop(context);
                  _addFile(context, "image");
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Añadir video"),
                onTap: () {
                  Navigator.pop(context);
                  _addFile(context, "video");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------- Eliminar archivo -------------------
  void _deleteFile(int index) {
    final file = _localFiles[index];

    // Si el archivo es un video, destruir su controlador
    if (file.type == 'video') {
      _videoControllers[file.key]?.dispose(); // Eliminar el controlador de video
      _videoControllers.remove(file.key); // Eliminarlo del mapa
    }

    setState(() {
      // Eliminar el archivo de la lista
      _localFiles.removeAt(index);

      // Si hemos eliminado el archivo actual, ajustar el índice
      if (_currentFileIndex >= _localFiles.length) {
        _currentFileIndex = _localFiles.isEmpty ? 0 : _localFiles.length - 1;
      }
    });
    widget.onFileChanged?.call("delete", index, file);
  }

  // ------------------- Agregar archivo -------------------
  Future<void> _addFile(BuildContext context, String type) async {
    final picked = await _pickFile(type, context);
    if (picked == null) return;

    final file = File(picked.path);
    if (!await file.exists()) return;

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
      // Si es audio y ya existe uno, reemplázalo
      if (type == "audio") {
        final existingIndex = _localFiles.indexWhere((f) => f.type == "audio");
        if (existingIndex != -1) {
          // Si ya hay un audio, reemplazarlo
          final oldAudio = _localFiles[existingIndex];

          // Notificar que se elimina el anterior
          widget.onFileChanged?.call("delete", existingIndex, oldAudio);

          // Reemplazarlo por el nuevo audio
          _localFiles[existingIndex] = newFile;
          widget.onFileChanged?.call("update", existingIndex, newFile);
          print("🔁 Reemplazado audio en índice $existingIndex");
          return;
        }
      }

      // Agregar nuevo archivo
      _localFiles.add(newFile);

      // Actualizar índice al nuevo archivo
      _currentFileIndex = _localFiles.length - 1;

      widget.onFileChanged?.call("add", null, newFile);
      print("✅ Archivo agregado: ${newFile.name}");
      print("🔹 _currentFileIndex actualizado: $_currentFileIndex");
      print("📁 Archivos totales: ${_localFiles.length}");
    });
  }

  // ------------------- Editar archivo -------------------
  Future<void> _editFile(BuildContext context, String type, {int? index}) async {
    final picked = await _pickFile(type, context);
    if (picked == null) return;

    final file = File(picked.path);
    if (!await file.exists()) return;

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
      // Buscar si ya hay un audio
      final existingIndex = _localFiles.indexWhere((f) => f.type == "audio");

      if (existingIndex != -1) {
        final oldAudio = _localFiles[existingIndex];

        // Notificar que se elimina el anterior (para que el padre lo borre del backend)
        widget.onFileChanged?.call("delete", existingIndex, oldAudio);

        // Reemplazarlo por el nuevo audio
        _localFiles[existingIndex] = newFile;
        widget.onFileChanged?.call("update", existingIndex, newFile);

      } else {
        // Si por alguna razón no existía, simplemente agregarlo
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
      if (!context.mounted) return null;
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
      Timer? timer;
      final FlutterSoundPlayer player = FlutterSoundPlayer();
      await player.openPlayer();

      if (!context.mounted) return null;

      final XFile? result = await showModalBottomSheet<XFile>(
        context: context,
        isScrollControlled: true,
        builder: (modalContext) => SafeArea(
          child: StatefulBuilder(
            builder: (modalContext, setModalState) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecording ? "Grabando..." : "Listo para grabar",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:"
                        "${recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

                            timer = Timer.periodic(const Duration(seconds: 1), (_) {
                              setModalState(() {
                                recordingDuration += const Duration(seconds: 1);
                              });
                            });

                            setModalState(() => isRecording = true);
                          } else {
                            await _recorder.stopRecorder();
                            timer?.cancel();
                            timer = null;
                            setModalState(() => isRecording = false);
                          }
                        },
                      ),
                      const SizedBox(width: 16),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(thickness: 1.5, color: Colors.grey[400]),
                  Column(
                    children: [
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          label: const Text("Usar Audio"),
                          onPressed: () => Navigator.pop(modalContext, recordedFile),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // Si se salió sin usar audio, eliminar el archivo temporal
      if (recordedFile != null && result == null) {
        final file = File(recordedFile!.path);
        if (await file.exists()) await file.delete();
        recordedFile = null;
      }
      await player.closePlayer();
      return result;
    }

    // --- Video / Imagen ---
    if (!context.mounted) return null;

    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (modalContext) => SafeArea(
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
                if (!modalContext.mounted) return;
                Navigator.pop(modalContext, picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(type == "video" ? "Grabar video" : "Tomar foto"),
              onTap: () async {
                final picked = type == "video"
                    ? await picker.pickVideo(source: ImageSource.camera)
                    : await picker.pickImage(source: ImageSource.camera);
                if (!modalContext.mounted) return;
                Navigator.pop(modalContext, picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _guessMimeType(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType ?? "application/octet-stream";
  }

}