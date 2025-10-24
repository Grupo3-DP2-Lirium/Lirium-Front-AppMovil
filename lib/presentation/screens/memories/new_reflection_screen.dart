import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  
  List<ReflectionFile> _attachedFiles = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingReflection != null) {
      _titleController.text = widget.editingReflection!.title;
      _contentController.text = widget.editingReflection!.content;
      _attachedFiles = List.from(widget.editingReflection!.attachedFiles);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processPickedFile(File(image.path), ReflectionFileType.image);
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar la imagen: $e');
    }
  }

  Future<void> _recordAudio() async {
    if (_reflectionService.userType == UserType.free) {
      _showPremiumRequiredDialog('grabar audio');
      return;
    }
    
    // TODO: Implementar grabación de audio
    _showErrorDialog('Función de audio en desarrollo');
  }

  Future<void> _processPickedFile(File file, ReflectionFileType type) async {
    try {
      final fileSize = await file.length();
      
      // Verificar límite de almacenamiento para usuarios gratuitos
      if (!await _reflectionService.canAttachFile(fileSize)) {
        _showStorageLimitDialog();
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
        id: widget.editingReflection?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Éxito!'),
        content: const Text('Tu reflexión ha sido creada con éxito'),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
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
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                        icon: Icons.mic_none_outlined,
                        tooltip: 'Audio',
                        onPressed: _recordAudio,
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
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 24,
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
                  ? Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        file.isAudio ? Icons.audiotrack : Icons.videocam,
                        size: 32,
                        color: Colors.grey.shade600,
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