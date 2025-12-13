import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart' as domain;
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/image_improvement_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_controllers.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/fields_widget.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/files_preview_widget.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/improve_picture.dart';
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
  final DateController photoDateController;
  final LocationController locationController;
  final double screenHeight;
  final bool edit;
  final bool create;
  final List<domain.File>? existingFiles;
  final void Function(String action, [int? index, domain.File? file])? onFileChanged;

  const MemoryContainer({
    super.key,
    required this.memory,
    required this.titleController,
    required this.descriptionController,
    required this.photoDateController,
    required this.locationController,
    required this.screenHeight,
    this.edit = false,
    this.create = false,
    this.onFileChanged,
    this.existingFiles,
  });

  @override
  State<MemoryContainer> createState() => _MemoryContainerState();
}

class _MemoryContainerState extends State<MemoryContainer> with AutomaticKeepAliveClientMixin {
  late List<domain.File> _localFiles;
  final picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  int _currentFileIndex = 0;
  final Map<Key, VideoPlayerController> _videoControllers = {};
  bool _isEditing = false;
  bool _isCreating = false;
  late final bool _hadOriginalFiles;

  // 🔥 CONSTANTES DE VALIDACIÓN
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB en bytes
  static const int maxTotalSizeBytes = 200 * 1024 * 1024; // 200MB en bytes

  void setEditMode(bool value) {
    if (!mounted) return;
    setState(() {
      _isEditing = value;
    });
  }

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
    _isCreating = widget.create;
    _initRecorder();
    _hadOriginalFiles = (widget.existingFiles?.isNotEmpty ?? false);
  }

  @override
  void didUpdateWidget(covariant MemoryContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrls = (oldWidget.existingFiles ?? []).map((f) => f.url).toList();
    final newUrls = (widget.existingFiles ?? []).map((f) => f.url).toList();
    if (oldUrls.join(',') != newUrls.join(',')) {
      setState(() {
        _localFiles = List.from(widget.existingFiles ?? []);
        if (_currentFileIndex >= _localFiles.length) {
          _currentFileIndex = _localFiles.isEmpty ? 0 : _localFiles.length - 1;
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _recorder.closeRecorder();
    super.dispose();
  }

  // 🔥 MÉTODO: Calcular tamaño total de archivos
  int _calculateTotalFileSize() {
    int total = 0;

    // Sumar archivos existentes
    for (var file in _localFiles) {
      total += file.size.toInt();
    }

    return total;
  }

  // 🔥 MÉTODO: Validar tamaño individual del archivo
  Future<bool> _validateFileSize(File file, BuildContext context) async {
    final fileSize = await file.length();

    if (fileSize > maxFileSizeBytes) {
      final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

      if (!context.mounted) return false;

      await appPopupButtonDefault(
        context: context,
        title: "Archivo demasiado grande",
        message: "El archivo seleccionado pesa $sizeMB MB.\n\n"
            "El tamaño máximo permitido es de 100 MB por archivo.",
        buttons: [
          AppPopupButton(
            text: "Entendido",
            onPressed: () {},
          ),
        ],
      );

      return false;
    }

    return true;
  }

  // 🔥 MÉTODO: Validar tamaño total de todos los archivos
  Future<bool> _validateTotalSize(int newFileSize, BuildContext context) async {
    final currentTotal = _calculateTotalFileSize();
    final projectedTotal = currentTotal + newFileSize;

    if (projectedTotal > maxTotalSizeBytes) {
      final currentMB = (currentTotal / (1024 * 1024)).toStringAsFixed(2);
      final newFileMB = (newFileSize / (1024 * 1024)).toStringAsFixed(2);
      final projectedMB = (projectedTotal / (1024 * 1024)).toStringAsFixed(2);

      if (!context.mounted) return false;

      await appPopupButtonDefault(
        context: context,
        title: "Límite de almacenamiento excedido",
        message: "Ya tienes $currentMB MB en archivos.\n"
            "El nuevo archivo pesa $newFileMB MB.\n\n"
            "Total proyectado: $projectedMB MB\n"
            "Límite máximo: 200 MB\n\n"
            "Por favor, elimina algunos archivos antes de continuar.",
        buttons: [
          AppPopupButton(
            text: "Entendido",
            onPressed: () {},
          ),
        ],
      );

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_localFiles.isNotEmpty) {
      final file = _localFiles.first;
      final fileType = file.type;
      final previewHeight =
      fileType == "audio" ? widget.screenHeight * 0.10 : widget.screenHeight * 0.40;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fileType == "audio") _buildQA(hideDescription: _localFiles.isNotEmpty && _localFiles.first.type == "audio"),
            PreviewWidget(
              localFiles: _localFiles,
              currentFileIndex: _currentFileIndex,
              isEditing: _isEditing || _isCreating,
              deleteFile: _deleteFile,
              editFile: _editFile,
              showAddOptions: _showAddOptions,
              height: previewHeight,
              videoControllers: _videoControllers,
            ),
            MemoryFormulario(
              memory: widget.memory,
              isEditing: _isEditing || _isCreating,
              titleController: widget.titleController,
              descriptionController: widget.descriptionController,
              photoDateController: widget.photoDateController,
              locationController: widget.locationController,
            ),
          ],
        ),
      );
    }
    if ((_localFiles.isEmpty && _hadOriginalFiles) || widget.create) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PreviewWidget(
              localFiles: _localFiles,
              currentFileIndex: _currentFileIndex,
              isEditing: _isEditing || _isCreating,
              deleteFile: _deleteFile,
              editFile: _editFile,
              showAddOptions: _showAddOptions,
              height: widget.screenHeight * 0.40,
              videoControllers: _videoControllers,
            ),
            MemoryFormulario(
              memory: widget.memory,
              isEditing: _isEditing || _isCreating,
              titleController: widget.titleController,
              descriptionController: widget.descriptionController,
              photoDateController: widget.photoDateController,
              locationController: widget.locationController,
            ),
          ],
        ),
      );
    }
    return _buildQA();
  }

  Widget _buildQA({bool hideDescription = false}) {
    final hasQuestion = widget.memory.associatedQuestion != null &&
        widget.memory.associatedQuestion!.trim().isNotEmpty;

    final personName = "esa persona";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            if (hasQuestion)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // azul
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded,
                        size: 32, color: Colors.blue[400]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pregunta",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.memory.associatedQuestion!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ================= CARTA PERSONAL =================
            if (!hasQuestion)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5), // morado suave
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mail_rounded,
                        size: 32, color: Colors.purple[400]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Carta personal",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "¿Qué te gustaría decirle a $personName?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ================= TEXTO =================
            if (!hideDescription)
              AppTextField(
                hintText: hasQuestion
                    ? "Escribe la respuesta"
                    : "Escribe tu carta aquí",
                controller: widget.descriptionController,
                enabled: _isEditing,
                maxLines: 20,
                validator: (v) =>
                (v == null || v.isEmpty) ? "Este campo es obligatorio" : null,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    print('🎬 _showAddOptions llamado');

    try {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (modalContext) {
          print('✅ Modal builder ejecutado');
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Añadir imagen"),
                  onTap: () {
                    print('📸 Opción imagen seleccionada');
                    Navigator.pop(modalContext);
                    _addFile(context, "image");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text("Añadir video"),
                  onTap: () {
                    print('🎥 Opción video seleccionada');
                    Navigator.pop(modalContext);
                    _addFile(context, "video");
                  },
                ),
              ],
            ),
          );
        },
      ).then((value) {
        print('✅ Modal cerrado con resultado: $value');
      }).catchError((error) {
        print('❌ Error en modal: $error');
      });
    } catch (e, stackTrace) {
      print('❌ Error al abrir modal: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _deleteFile(int index) {
    final file = _localFiles[index];
    if (file.type == 'video') {
      _videoControllers[file.key]?.dispose();
      _videoControllers.remove(file.key);
    }
    setState(() {
      _localFiles.removeAt(index);
      if (_currentFileIndex >= _localFiles.length) {
        _currentFileIndex = _localFiles.isEmpty ? 0 : _localFiles.length - 1;
      }
    });
    widget.onFileChanged?.call("delete", index, file);
  }

  // =============== ACTUALIZADO: Flujo con validaciones ===============
  Future<void> _addFile(BuildContext context, String type) async {
    if (type == "image") {
      await _addImageWithImprovement(context);
      return;
    }

    // Para video y audio, mantener el flujo original
    final picked = await _pickFile(type, context);
    if (picked == null) return;
    final file = File(picked.path);
    if (!await file.exists()) return;

    // 🔥 VALIDACIÓN 1: Tamaño individual
    if (!await _validateFileSize(file, context)) {
      return; // Detener si excede 100MB
    }

    final fileSize = await file.length();

    // 🔥 VALIDACIÓN 2: Tamaño total
    if (!await _validateTotalSize(fileSize, context)) {
      return; // Detener si excede 200MB total
    }

    final newFile = domain.File(
      id: "",
      url: picked.path,
      name: picked.name,
      type: type,
      mimeType: _guessMimeType(picked.path),
      size: fileSize.toDouble(),
      uploadedDate: DateTime.now(),
      originalName: picked.name,
    );

    setState(() {
      if (type == "audio") {
        final existingIndex = _localFiles.indexWhere((f) => f.type == "audio");
        if (existingIndex != -1) {
          final oldAudio = _localFiles[existingIndex];
          widget.onFileChanged?.call("delete", existingIndex, oldAudio);
          _localFiles[existingIndex] = newFile;
          widget.onFileChanged?.call("update", existingIndex, newFile);
          return;
        }
      }
      _localFiles.add(newFile);
      _currentFileIndex = _localFiles.length - 1;
      widget.onFileChanged?.call("add", null, newFile);
    });
  }

  // =============== ACTUALIZADO: Agregar validaciones para imágenes ===============
  Future<void> _addImageWithImprovement(BuildContext context) async {
    print('🎬 _addImageWithImprovement iniciado');

    try {
      // PASO 1: Elegir fuente (Galería o Cámara)
      print('📋 Abriendo modal de selección de fuente...');
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (modalContext) {
          print('✅ Modal de fuente construido');
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Galería de imágenes"),
                  onTap: () {
                    print('📸 Usuario seleccionó Galería');
                    Navigator.pop(modalContext, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Tomar foto"),
                  onTap: () {
                    print('📷 Usuario seleccionó Cámara');
                    Navigator.pop(modalContext, ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (source == null) {
        print('❌ Usuario canceló selección de fuente');
        return;
      }

      if (!context.mounted) {
        print('❌ Context no disponible después de selección');
        return;
      }

      print('🎯 Source seleccionado: $source');
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;

      // PASO 2: Seleccionar imagen
      print('📸 Seleccionando imagen...');
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile == null) {
        print('❌ No se seleccionó imagen');
        return;
      }

      print('✅ Imagen seleccionada: ${pickedFile.path}');

      // 🔥 VALIDACIÓN TEMPRANA: Verificar tamaño antes de continuar
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        print('❌ El archivo no existe');
        return;
      }

      if (!await _validateFileSize(file, context)) {
        return; // Detener si excede 100MB
      }

      final fileSize = await file.length();

      if (!await _validateTotalSize(fileSize, context)) {
        return; // Detener si excede 200MB total
      }

      if (!context.mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      if (!context.mounted) return;

      print('🤔 Preguntando si desea mejorar con IA...');

      final bool? shouldEnhance = await showModalBottomSheet<bool>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (modalContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Mejorar imagen con IA?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Solo se pueden subir imágenes hasta de 1MB. '
                      'Ampliación de límite pensada próximamente… 😉',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // --- Primero: "Usar sin mejora" ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(modalContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Usar sin mejora'),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Segundo: "Mejorar con IA" ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Mejorar con IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(modalContext, true),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (shouldEnhance == null) {
        print('❌ Usuario canceló decisión de mejora');
        return;
      }

      if (!context.mounted) return;

      String finalImagePath;

      if (shouldEnhance) {
        // FLUJO CON MEJORA: Ir directo a ImageImprovementScreen
        print('🚀 Usuario eligió mejorar con IA, navegando directo a mejora...');
        await Future.delayed(const Duration(milliseconds: 300));

        if (!context.mounted) return;

        final String? enhancedPath = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (ctx) {
              print('🏗️ Construyendo ImageImprovementScreen directamente');
              return ImageImprovementScreen(imagePath: pickedFile.path);
            },
          ),
        );

        print('✅ Retornó de ImageImprovementScreen con: $enhancedPath');

        if (enhancedPath == null) {
          print('❌ Usuario canceló en flujo de mejora');
          return;
        }

        finalImagePath = enhancedPath;
      } else {
        // FLUJO DIRECTO: Usar imagen sin mejora
        print('⚡ Usuario eligió usar sin mejora');
        finalImagePath = pickedFile.path;
      }

      if (!context.mounted) return;

      // PASO FINAL: Agregar imagen a la lista
      print('📁 Verificando archivo: $finalImagePath');
      final finalFile = File(finalImagePath);
      if (!await finalFile.exists()) {
        print('❌ El archivo no existe: $finalImagePath');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: El archivo de imagen no existe'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 🔥 REVALIDAR después de mejora (por si cambió el tamaño)
      if (!await _validateFileSize(finalFile, context)) {
        return;
      }

      final finalFileSize = await finalFile.length();

      if (!await _validateTotalSize(finalFileSize, context)) {
        return;
      }

      print('✅ Archivo válido, creando domain.File...');

      final newFile = domain.File(
        id: "",
        url: finalImagePath,
        name: finalImagePath.split('/').last,
        type: "image",
        mimeType: _guessMimeType(finalImagePath),
        size: finalFileSize.toDouble(),
        uploadedDate: DateTime.now(),
        originalName: finalImagePath.split('/').last,
      );

      if (!mounted) {
        print('❌ Widget no montado, no se puede actualizar estado');
        return;
      }

      setState(() {
        _localFiles.add(newFile);
        _currentFileIndex = _localFiles.length - 1;
        widget.onFileChanged?.call("add", null, newFile);
      });

      print('✅ Imagen agregada exitosamente a _localFiles (total: ${_localFiles.length})');

      // Mostrar confirmación
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shouldEnhance
                ? '✨ Imagen mejorada agregada'
                : '📸 Imagen agregada'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e, stackTrace) {
      print('❌ Error en _addImageWithImprovement: $e');
      print('Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editFile(BuildContext context, String type, {int? index}) async {
    final picked = await _pickFile(type, context);
    if (picked == null) return;
    final file = File(picked.path);
    if (!await file.exists()) return;

    // 🔥 VALIDACIÓN 1: Tamaño individual
    if (!await _validateFileSize(file, context)) {
      return;
    }

    final fileSize = await file.length();

    // Para edición de audio, calcular sin el audio actual
    int currentTotal = _calculateTotalFileSize();
    final existingIndex = _localFiles.indexWhere((f) => f.type == "audio");
    if (existingIndex != -1) {
      currentTotal -= _localFiles[existingIndex].size.toInt();
    }

    // VALIDACIÓN 2: Tamaño total (sin contar el audio que se va a reemplazar)
    final projectedTotal = currentTotal + fileSize;
    if (projectedTotal > maxTotalSizeBytes) {
      final currentMB = (currentTotal / (1024 * 1024)).toStringAsFixed(2);
      final newFileMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      final projectedMB = (projectedTotal / (1024 * 1024)).toStringAsFixed(2);

      if (!context.mounted) return;

      await appPopupButtonDefault(
        context: context,
        title: "Límite de almacenamiento excedido",
        message: "Archivos actuales (sin audio): $currentMB MB.\n"
            "El nuevo archivo pesa $newFileMB MB.\n\n"
            "Total proyectado: $projectedMB MB\n"
            "Límite máximo: 200 MB\n\n"
            "Por favor, elimina algunos archivos antes de continuar.",
        buttons: [
          AppPopupButton(
            text: "Entendido",
            onPressed: () {},
          ),
        ],
      );
      return;
    }

    final newFile = domain.File(
      id: "",
      url: picked.path,
      name: picked.name,
      type: type,
      mimeType: _guessMimeType(picked.path),
      size: fileSize.toDouble(),
      uploadedDate: DateTime.now(),
      originalName: picked.name,
    );

    setState(() {
      final existingIndex = _localFiles.indexWhere((f) => f.type == "audio");
      if (existingIndex != -1) {
        final oldAudio = _localFiles[existingIndex];
        widget.onFileChanged?.call("delete", existingIndex, oldAudio);
        _localFiles[existingIndex] = newFile;
        widget.onFileChanged?.call("update", existingIndex, newFile);
      } else {
        _localFiles.add(newFile);
        widget.onFileChanged?.call("add", null, newFile);
      }
    });
  }

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
      if (recordedFile != null && result == null) {
        final file = File(recordedFile!.path);
        if (await file.exists()) await file.delete();
        recordedFile = null;
      }
      await player.closePlayer();
      return result;
    }
    // Para video
    if (!context.mounted) return null;
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galería de videos"),
              onTap: () async {
                final picked = await picker.pickVideo(source: ImageSource.gallery);
                if (!modalContext.mounted) return;
                Navigator.pop(modalContext, picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Grabar video"),
              onTap: () async {
                final picked = await picker.pickVideo(source: ImageSource.camera);
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