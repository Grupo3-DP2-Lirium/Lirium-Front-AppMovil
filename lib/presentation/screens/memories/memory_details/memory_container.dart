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
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class MemoryContainer extends StatefulWidget {
  final Memory memory;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final double screenHeight;
  final bool edit;
  final List<domain.File>? existingFiles;
  final void Function(String action, [int? index, domain.File? file])? onFileChanged;

  const MemoryContainer({
    super.key,
    required this.memory,
    required this.titleController,
    required this.descriptionController,
    required this.screenHeight,
    this.edit = false,
    this.onFileChanged,
    this.existingFiles,
  });

  @override
  State<MemoryContainer> createState() => _MemoryContainerState();
}

class _MemoryContainerState extends State<MemoryContainer>
    with AutomaticKeepAliveClientMixin {

  late List<domain.File> _localFiles; // copia editable
  final picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  int _currentFileIndex = 0;

  Map<Key, VideoPlayerController> _videoControllers = {};

  // estado interno de edición (inicializa desde widget.edit en initState)
  bool _isEditing = false;

  // Método público que permite al padre cambiar el modo sin recrear el widget
  void setEditMode(bool value) {
    if (!mounted) return;
    setState(() {
      _isEditing = value;
    });
  }

  // 🔄 Restaura los archivos originales y texto
  void restoreOriginalFiles(List<domain.File> originalFiles) {
    if (!mounted) return;
    setState(() {
      _localFiles = List.from(originalFiles);
      _currentFileIndex = 0;
    });
  }

  @override
  bool get wantKeepAlive => true;

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
    _localFiles = List.from(widget.existingFiles ?? []);
    _isEditing = widget.edit;
    _initRecorder();
  }

  // Detectar cambios en existingFiles
  @override
  void didUpdateWidget(covariant MemoryContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldUrls = (oldWidget.existingFiles ?? []).map((f) => f.url).toList();
    final newUrls = (widget.existingFiles ?? []).map((f) => f.url).toList();

    // Solo actualizar si cambió el contenido del padre (agregó/reemplazó archivos)
    if (oldUrls.join(',') != newUrls.join(',')) {
      // Evitamos resetear _currentFileIndex si ya teníamos archivos
      setState(() {
        _localFiles = List.from(widget.existingFiles ?? []);

        // Mantener el índice actual dentro del rango
        if (_currentFileIndex >= _localFiles.length) {
          _currentFileIndex = _localFiles.isEmpty ? 0 : _localFiles.length - 1;
        }
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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

    return const Text("Tipo de memoria no soportado");
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

  // ------------------- Vista previa -------------------
  Widget _buildPreview(String type, String url, double height, BuildContext context) {
    final multiple = _localFiles.length > 1;

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: _localFiles.isEmpty
          ? Center(
        child: OutlinedButton.icon(
          onPressed: () => _showAddOptions(context),
          icon: const Icon(Icons.add, color: Colors.black87),
          label: const Text(
            "Añadir imágenes o videos",
            style: TextStyle(color: Colors.black87),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      )
          : Stack(
        fit: StackFit.expand,
        children: [
          // Carrusel de archivos
      PageView.builder(
      controller: PageController(initialPage: _currentFileIndex),
      itemCount: _localFiles.length,
      onPageChanged: (index) {
        setState(() {
          _currentFileIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final file = _localFiles[index];

        // Si el archivo es un video y no se ha creado un controlador, crearlo
        if (file.type == 'video' && !_videoControllers.containsKey(file.key)) {
          _videoControllers[file.key] = VideoPlayerController.network(file.url)
            ..initialize().then((_) {
              setState(() {}); // Actualizar el estado después de inicializar el controlador
            });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FilePreview(
                key: PageStorageKey(file.key),
                videoController: _videoControllers[file.key],
                type: file.type,
                url: file.url,
              ),
            ),
          ],
        );
      },
    ),

    if (_isEditing)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _deleteFile(_currentFileIndex),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),

            // Contador (bottom-right)
            if (multiple)
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
                    "${_currentFileIndex + 1}/${_localFiles.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),

          if (_isEditing)
          // Botón flotante centrado abajo (igual que antes)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddOptions(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Añadir imágenes o videos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.85),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
              enabled: _isEditing,
              validator: (v) => (v == null || v.isEmpty) ? "El título es obligatorio" : null,
            ),
          ),
        AppTextField(
          hintText: "Escribe una descripción",
          maxLines: 10,
          controller: widget.descriptionController,
          enabled: _isEditing,
          validator: (v) =>
          (v == null || v.isEmpty) ? "La descripción es obligatoria" : null,
        ),
      ],
    ),
  );

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
          _localFiles[existingIndex] = newFile;
          widget.onFileChanged?.call("update", existingIndex, newFile);
          return;
        }
      }

      // Si no, agregarlo normalmente
      _localFiles.add(newFile);
      widget.onFileChanged?.call("add", null, newFile);
    });
  }

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