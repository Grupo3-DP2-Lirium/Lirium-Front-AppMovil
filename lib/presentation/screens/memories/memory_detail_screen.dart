import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_container.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_created_screen.dart';
import '../../../domain/entities/memory.dart';
import '../../components/buttons/switch_button.dart';
import 'dart:io' as io;

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final _service = MemoryService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _addTags = false;
  bool _isLoading = false;

  late Memory _originalMemory;
  late Memory _editableMemory;

  List<File> _existingFiles = [];
  List<io.File> _newFiles = [];
  List<File> _deletedFiles = [];

  @override
  void initState() {
    super.initState();
    _originalMemory = widget.memory;
    _editableMemory = _originalMemory.copyWith();
    _existingFiles = List.from(_editableMemory.files);
    _titleController = TextEditingController(text: _editableMemory.title);
    _descriptionController = TextEditingController(text: _editableMemory.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Services
  Future<void> _saveChanges() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final memoryJson = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "addTags": _addTags,
      };

      final filesToUpload = _newFiles.isNotEmpty ? _newFiles : null;
      final filesToDelete = _deletedFiles
          .map((f) => {"id": f.id, "path": f.url})
          .toList();

      print('Files to upload: ${filesToUpload?.map((f) => f.path).toList()}');
      print('Files to delete: $filesToDelete');

      // Llamada al servicio
      await _service.updateMemory(
        memoryId: widget.memory.id,
        memoryJson: memoryJson,
        files: filesToUpload,
        filesToDelete: filesToDelete,
      );

      // Actualizamos modelo local
      final updatedMemory = _editableMemory.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        files: [
          // Archivos que quedan
          ..._editableMemory.files.where((f) => !_newFiles.any((nf) => nf.path == f.url)),
          // Archivos nuevos
          ..._newFiles.map((f) => File(
            id: '', // backend asignará
            url: f.path,
            name: f.path.split('/').last,
            type: 'local',
            mimeType: '',
            size: 0,
            uploadedDate: DateTime.now(),
            originalName: f.path.split('/').last,
          )),
        ],
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryCreatedScreen(memory: updatedMemory),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar memoria'),
        content: const Text('¿Estás seguro de que quieres eliminar esta memoria? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Implementar el metodo de deleteMemory

      if (mounted) {
        Navigator.pop(context, true); // Indica que se eliminó la memoria
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título + botón eliminar (adaptable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: AppTitle(title: "Vista previa"),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: PrimaryButton(
                    onPressed: _deleteMemory,
                    icon: Icons.delete,
                    text: "Eliminar",
                    isFullWidth: false,
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: SingleChildScrollView(
                child: MemoryContainer(
                  memory: memory,
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  screenHeight: screenHeight,
                  onFileChanged: (action, [index, file]) async {
                    if (file != null) {
                      final localPath = file.url;
                      if (localPath != null && localPath.isNotEmpty) {
                        final ioFile = io.File(localPath);
                        setState(() {
                          if (action == "add") {
                            // Nuevo archivo agregado
                            _newFiles.add(ioFile);
                          } else if (action == "update" && index != null) {
                            // Archivo existente reemplazado → agregarlo a eliminados
                            final replacedFile = _editableMemory.files[index];
                            if (_existingFiles.contains(replacedFile)) {
                              _deletedFiles.add(replacedFile);
                            }
                            // Actualizar el archivo nuevo en la lista
                            if (index < _newFiles.length) {
                              _newFiles[index] = ioFile;
                            } else {
                              _newFiles.add(ioFile);
                            }
                          }
                        });
                      }
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Footer fijo abajo con switch encima
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.inactive, width: 1), // línea arriba del footer
                ),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch IA tags
                  /*Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: BooleanSelectorSwitch(
                      value: _addTags,
                      onChanged: (val) {
                        setState(() {
                          _addTags = val;
                        });
                      },
                      label: 'Agregar etiquetas de IA',
                      subtitle: 'Para poder clasificar mejor tu recuerdo',
                      withBackground: false,
                    ),
                  ),*/

                  const SizedBox(height: 12), // espacio entre switch y botones

                  // Botones del footer
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: "Cancelar",
                          isOutlined: true,
                          textColor: AppColors.primary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: PrimaryButton(
                          text: "Guardar",
                          onPressed: _saveChanges,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}