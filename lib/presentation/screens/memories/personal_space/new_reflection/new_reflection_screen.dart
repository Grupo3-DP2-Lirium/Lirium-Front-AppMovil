import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/new_reflection/toolbar_widget.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/audio_player.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/image_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/video_player.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../../data/models/reflection_model.dart';
import '../../../../../data/services/reflection_service.dart';
import '../../../../../providers/reflection_provider.dart';
import '../../../../components/common/app_bar.dart';
import '../../../../components/common/app_pop_up.dart';
import 'attachments_preview.dart';

class NewReflectionScreen extends StatefulWidget {
  final ReflectionModel? editingReflection;
  
  const NewReflectionScreen({
    super.key,
    this.editingReflection,
  });

  @override
  State<NewReflectionScreen> createState() => _NewReflectionScreenState();
}

class _NewReflectionScreenState extends State<NewReflectionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ReflectionService _reflectionService = ReflectionService();
  final ImagePicker _imagePicker = ImagePicker();
  
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  List<ReflectionFile> _attachedFiles = [];
  bool _isSaving = false;
  bool _isRecording = false;

  Map<String, VideoPlayerController> _videoControllers = {};
  Set<String> _uploadingFiles = {};

  @override
  void initState() {
    super.initState();
    if (widget.editingReflection != null) {
      _titleController.text = widget.editingReflection!.title;
      _contentController.text = widget.editingReflection!.content;
      _attachedFiles = List.from(widget.editingReflection!.attachedFiles);
      _initExistingVideoControllers();
    }
    _initializeRecorder();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _audioRecorder?.closeRecorder();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initExistingVideoControllers() async {
    for (final file in _attachedFiles.where((f) => f.isVideo)) {
      if (!_videoControllers.containsKey(file.localPath)) {
        final controller = VideoPlayerController.file(File(file.localPath!));
        await controller.initialize();
        controller.setLooping(true);
        controller.pause();
        _videoControllers[file.localPath!] = controller;
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_reflectionService.userType == UserType.free) {
      _showPremiumRequiredDialog('adjuntar fotos');
      return;
    }
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processPickedFile(File(image.path), ReflectionFileType.image);
      }
    } catch (e) {
      _showErrorDialog('Error al tomar la foto: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_reflectionService.userType == UserType.free) {
      _showPremiumRequiredDialog('adjuntar imágenes');
      return;
    }
    try {
      // Mostrar diálogo de selección entre imagen y video
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar archivo'),
          content: const Text('¿Qué tipo de archivo deseas adjuntar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'image'),
              child: const Text('Imagen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'video'),
              child: const Text('Video'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (result == null) return;

      if (result == 'image') {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          await _processPickedFile(File(image.path), ReflectionFileType.image);
        }
      } else if (result == 'video') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          await _processPickedFile(File(result.files.single.path!), ReflectionFileType.video);
        }
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar archivo: $e');
    }
  }

  Future<void> _initializeRecorder() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();
      _isRecorderInitialized = true;
    } catch (e) {
      _isRecorderInitialized = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al inicializar grabador de audio')),
        );
      }
    }
  }

  Future<bool> _checkPermissions() async {
    return await Permission.microphone.isGranted || 
           await Permission.microphone.request().isGranted;
  }

  Future<void> _recordAudio() async {
    if (_reflectionService.userType == UserType.free) {
      _showPremiumRequiredDialog('grabar audio');
      return;
    }

    try {
      if (!_isRecording) {
        // Iniciar grabación
        await _startRecording();
      } else {
        // Detener grabación
        await _stopRecording();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _showErrorDialog('Error al grabar audio: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grabador de audio no inicializado')),
        );
      }
      return;
    }

    if (!await _checkPermissions()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se requiere permiso de micrófono')),
        );
      }
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      _audioPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      await _audioRecorder!.startRecorder(
        toFile: _audioPath!,
        codec: Codec.aacADTS,
      );

      setState(() => _isRecording = true);
      _startTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grabando audio... Toca de nuevo para detener'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar grabación')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _audioRecorder == null) return;

    try {
      await _audioRecorder!.stopRecorder();
      _stopTimer();
      
      if (_audioPath != null && mounted) {
        setState(() {
          _isRecording = false;
        });
        
        await _processPickedFile(File(_audioPath!), ReflectionFileType.audio);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio grabado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al detener grabación')),
        );
      }
    }
  }

  void _startTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<void> _processPickedFile(File file, ReflectionFileType type) async {
    try {
      setState(() {
        _uploadingFiles.add(file.path);
      });

      final fileSize = await file.length();

      // Verificar límite de almacenamiento para usuarios gratuitos
      if (!await _reflectionService.canAttachFile(fileSize)) {
        _showStorageLimitDialog();
        return;
      }

      final subscriptionProvider = context.read<SubscriptionProvider>();
      final maxFiles = subscriptionProvider.maxFiles; // Puede ser null = ilimitado
      final planName = subscriptionProvider.planName;

      final reflections = await _reflectionService.getAllReflections();
      int totalAttachedFiles = reflections.fold(
          0, (sum, r) => sum + r.attachedFiles.length);

      // Agregar también los archivos de la reflexión actual
      totalAttachedFiles += _attachedFiles.length;

      if (maxFiles == null) {
        print('Tu plan "$planName" permite adjuntar una cantidad ilimitada de archivos.');
      } else {
        print('Tu plan permite adjuntar hasta $maxFiles archivos.');
        print('Actualmente tienes $totalAttachedFiles archivos adjuntos en todas tus reflexiones.');
      }

      if (maxFiles != null && totalAttachedFiles >= maxFiles) {
        _showErrorDialog(
            'Has alcanzado el límite de $maxFiles archivos para tu plan.'
        );
        return;
      }

      final reflectionFile = await _reflectionService.copyFileToReflectionsDirectory(file, type);

      // Vista Previa del Video
      if (type == ReflectionFileType.video) {
        final localPath = reflectionFile.localPath;

        if (localPath != null) {
          final controller = VideoPlayerController.file(File(localPath));

          await controller.initialize();
          controller.setLooping(true);
          controller.pause();

          _videoControllers[localPath] = controller;
        }
      }

      setState(() {
        _attachedFiles.add(reflectionFile);
      });

    } catch (e) {
      _showErrorDialog('Error al procesar el archivo: $e');
    } finally {
      setState(() {
        _uploadingFiles.remove(file.path);
      });    }
  }

  void _removeAttachedFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  Future<void> _saveReflection() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      _showErrorDialog('Debes escribir al menos un título o contenido');
      return;
    }
    // Mostrar popup de cargando
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    try {
      final reflection = ReflectionModel(
        id: widget.editingReflection?.id ?? '',
        title: title,
        content: content,
        createdDate: widget.editingReflection?.createdDate ?? DateTime.now(),
        attachedFiles: _attachedFiles,
      );

      print("ID que se está enviando al editar: ${reflection.id}");

      await _reflectionService.saveReflection(reflection);

      if (mounted) {
        final provider = Provider.of<ReflectionProvider>(context, listen: false);
        await provider.refreshReflections();
      }

      if (!mounted) return;

      Navigator.pop(context);

      final isEditing = widget.editingReflection != null;
      // Popup según si es creación o edición
      await appPopupButtonDefault(
        context: context,
        title: isEditing
            ? "Tu reflexión ha sido actualizada"
            : "Tu reflexión ha sido creada",
        message: isEditing
            ? "Los cambios se guardaron correctamente."
            : "Gracias por compartir un momento más de tu historia.",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context, true);
              if (isEditing) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await appPopupButtonDefault(
        context: context,
        title: "Error",
        message: "Error al guardar la reflexión: $e",
        buttons: [
          AppPopupButton(
            text: "Cerrar",
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
  }

  bool _hasChanges() {
    if (widget.editingReflection == null) return false;

    return _titleController.text.trim() != widget.editingReflection!.title ||
        _contentController.text.trim() != widget.editingReflection!.content ||
        _attachedFiles.length != widget.editingReflection!.attachedFiles.length;
  }

  void _showPremiumRequiredDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Función Premium'),
        content: Text(
          'La función de $feature está disponible solo para usuarios premium. '
          'Actualiza tu cuenta para acceder a todas las funciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navegar a pantalla de upgrade
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showStorageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Límite de Almacenamiento'),
        content: const Text(
          'Has alcanzado el límite de almacenamiento de 100 MB para usuarios gratuitos. '
          'Elimina algunos archivos o actualiza a premium para obtener más espacio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navegar a pantalla de upgrade
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExitEditDialog() {
    appPopupButtonDefault(
      context: context,
      title: "¿Estás seguro?",
      message: "Tienes cambios no guardados. Si cancelas, perderás los cambios.",
      buttons: [
        AppPopupButton(
          text: "Cancelar",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        AppPopupButton(
          text: "Confirmar",
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: widget.editingReflection != null
            ? "Editar Reflexión"
            : "Nueva Reflexión",
        onBack: () {
          if (widget.editingReflection != null && _hasChanges()) {
            _showExitEditDialog();
          } else {
            Navigator.pop(context);
          }
        },
        appBarHeight: MediaQuery.of(context).size.height * 0.09,
        showBackButton: true,
        trailing: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: _isSaving ? null : _saveReflection,
            icon: _isSaving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            tooltip: 'Guardar',
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Editor principal
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de título
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      hintStyle: TextStyle(fontSize: 24, color: Colors.black26),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 4),

                  Divider(
                    color: Colors.grey,
                    thickness: 0.2,
                    height: 20,
                  ),

                  const SizedBox(height: 4),

                  // Campo de contenido
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Empezar a escribir...',
                        hintStyle: TextStyle(fontSize: 16, color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),

                  // Vista previa de archivos adjuntos
                  if (_attachedFiles.isNotEmpty || _uploadingFiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AttachmentsPreview(
                      attachedFiles: _attachedFiles,
                      videoControllers: _videoControllers,
                      onRemove: _removeAttachedFile,
                      onOpen: _openFile,
                      uploadingFiles: _uploadingFiles,
                    ),
                  ],
                ],
              ),
            ),

            // Barra de herramientas flotante
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE7E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ToolbarButton(
                        icon: Icons.photo_camera_outlined,
                        tooltip: 'Cámara',
                        onPressed: _takePhoto,
                      ),
                      ToolbarButton(
                        icon: _isRecording ? Icons.stop : Icons.mic_none_outlined,
                        tooltip: _isRecording ? 'Detener grabación' : 'Audio',
                        onPressed: _recordAudio,
                        isRecording: _isRecording,
                      ),
                      ToolbarButton(
                        icon: Icons.image_outlined,
                        tooltip: 'Galería',
                        onPressed: _pickFromGallery,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFile(ReflectionFile file) {
    if (file.isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImage(file: file),
        ),
      );
    } else if (file.isAudio) {
      _showAudioPlayer(file);
    } else if (file.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenVideoPlayer(file: file),
        ),
      );
    }
  }

  void _showAudioPlayer(ReflectionFile file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: AudioPlayerWidget(path: file.localPath!),
      ),
    );
  }
}