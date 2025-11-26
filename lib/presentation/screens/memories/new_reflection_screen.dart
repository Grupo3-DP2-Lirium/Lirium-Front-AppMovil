import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/reflection_model.dart';
import '../../../data/services/reflection_service.dart';

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
  
  // Audio recording variables (usando flutter_sound como en answer_question_screen)
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  
  List<ReflectionFile> _attachedFiles = [];
  bool _isSaving = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingReflection != null) {
      _titleController.text = widget.editingReflection!.title;
      _contentController.text = widget.editingReflection!.content;
      _attachedFiles = List.from(widget.editingReflection!.attachedFiles);
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

  // Métodos de inicialización y grabación de audio (basados en answer_question_screen)
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
      final fileSize = await file.length();

      // Verificar límite de almacenamiento para usuarios gratuitos
      if (!await _reflectionService.canAttachFile(fileSize)) {
        _showStorageLimitDialog();
        return;
      }

      final subscriptionProvider = context.read<SubscriptionProvider>();
      final maxFiles = subscriptionProvider.maxFiles; // Puede ser null = ilimitado
      final planName = subscriptionProvider.planName;

      // Traer todas las reflexiones para contar archivos ya existentes
      final reflections = await _reflectionService.getAllReflections();
      int totalAttachedFiles = reflections.fold(
          0, (sum, r) => sum + r.attachedFiles.length);

      // Agregar también los archivos de la reflexión actual que ya seleccionaste
      totalAttachedFiles += _attachedFiles.length;

      // Mostrar mensaje
      if (maxFiles == null) {
        print('Tu plan "$planName" permite adjuntar una cantidad ilimitada de archivos.');
      } else {
        print('Tu plan permite adjuntar hasta $maxFiles archivos.');
        print('Actualmente tienes $totalAttachedFiles archivos adjuntos en todas tus reflexiones.');
      }

      // Validar cantidad actual
      if (maxFiles != null && totalAttachedFiles >= maxFiles) {
        _showErrorDialog(
            'Has alcanzado el límite de $maxFiles archivos para tu plan.'
        );
        return;
      }

      final reflectionFile = await _reflectionService.copyFileToReflectionsDirectory(file, type);

      setState(() {
        _attachedFiles.add(reflectionFile);
      });

    } catch (e) {
      _showErrorDialog('Error al procesar el archivo: $e');
    }
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

    setState(() {
      _isSaving = true;
    });

    try {
      final reflection = ReflectionModel(
        id: widget.editingReflection?.id ?? '',
        title: title,
        content: content,
        createdDate: widget.editingReflection?.createdDate ?? DateTime.now(),
        attachedFiles: _attachedFiles,
      );

      await _reflectionService.saveReflection(reflection);

      if (!mounted) return;
      
      _showSuccessDialog();
      
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al guardar la reflexión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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

  void _showSuccessDialog() {
    final isEditing = widget.editingReflection != null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Éxito!'),
        content: Text(isEditing 
            ? 'Tu reflexión ha sido actualizada con éxito'
            : 'Tu reflexión ha sido creada con éxito'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context, true); // Volver a pantalla anterior
            },
            child: const Text('Continuar'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
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
                      color: colorScheme.primary,
                      size: 28,
                    ),
              tooltip: 'Guardar',
            ),
          ),
        ],
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
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 12),

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
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),

                  // Vista previa de archivos adjuntos
                  if (_attachedFiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAttachmentsPreview(),
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
                      _buildToolbarButton(
                        icon: Icons.photo_camera_outlined,
                        tooltip: 'Cámara',
                        onPressed: _takePhoto,
                      ),
                      _buildToolbarButton(
                        icon: _isRecording ? Icons.stop : Icons.mic_none_outlined,
                        tooltip: _isRecording ? 'Detener grabación' : 'Audio',
                        onPressed: _recordAudio,
                        isRecording: _isRecording,
                      ),
                      _buildToolbarButton(
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

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isRecording = false,
  }) {
    return Container(
      decoration: isRecording 
          ? BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: isRecording ? Colors.red : null,
        ),
        onPressed: onPressed,
        iconSize: 24,
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archivos adjuntos (${_attachedFiles.length})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _attachedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            
            return _buildFilePreview(file, index);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilePreview(ReflectionFile file, int index) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: file.isImage
                  ? (file.localPath != null
                      ? Image.file(
                          File(file.localPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        )
                      : file.downloadUrl.isNotEmpty
                        ? Image.network(
                            file.downloadUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image),
                          ))
                  : Container(
                      color: file.isAudio 
                          ? Colors.blue.shade50 
                          : Colors.purple.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            file.isAudio ? Icons.audiotrack : Icons.videocam,
                            size: 24,
                            color: file.isAudio 
                                ? Colors.blue.shade600 
                                : Colors.purple.shade600,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            file.isAudio ? 'Audio' : 'Video',
                            style: TextStyle(
                              fontSize: 10,
                              color: file.isAudio 
                                  ? Colors.blue.shade600 
                                  : Colors.purple.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // Botón de eliminar
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => _removeAttachedFile(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}