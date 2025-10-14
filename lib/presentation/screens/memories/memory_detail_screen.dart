import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_container.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_created_screen.dart';
import '../../../domain/entities/memory.dart';
import 'dart:io' as io;

// Modes: view, edit or create
enum MemoryMode { view, edit}

class MemoryDetailScreen extends StatefulWidget {
  final Memory? memory;
  final MemoryMode mode;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.mode = MemoryMode.view, // Default mode is view
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final _service = MemoryService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;
  late Memory _originalMemory;
  late Memory _editableMemory;

  List<File> _existingFiles = [];
  final List<io.File> _newFiles = [];
  final List<File> _deletedFiles = [];

  final bool _addTags = false;

  late MemoryMode _mode;
  void _switchToEditMode() {
    setState(() {
      _mode = MemoryMode.edit;
    });
  }

  void _cancelEdit() {
    setState(() {
      _mode = MemoryMode.view;

      // Restaurar memoria editable al original
      _editableMemory = _originalMemory.copyWith();

      // Restaurar los archivos existentes al MemoryContainer
      _existingFiles = List.from(_originalMemory.files);

      // Limpiar archivos nuevos y eliminados
      _newFiles.clear();
      _deletedFiles.clear();

      // Restaurar controladores de texto
      _titleController.text = _originalMemory.title ?? "";
      _descriptionController.text = _originalMemory.description ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    if (widget.memory != null) {
      // Edit / view existing memory
      _originalMemory = widget.memory!;
      _editableMemory = _originalMemory.copyWith();
    } else {
      // Create new memory
      _originalMemory = Memory(
        id: "",
        type: "default",
        title: "",
        description: "",
        photoDate: null,
        location: null,
        visible: true,
        tags: [],
        associatedQuestion: null,
        files: [],
        totalUsedSpace: 0,
        createdDate: DateTime.now(),
      );
      _editableMemory = _originalMemory.copyWith();
    }

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
  // Save changes (Edit mode)
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

      await _service.updateMemory(
        memoryId: widget.memory!.id,
        memoryJson: memoryJson,
        files: filesToUpload,
        filesToDelete: filesToDelete,
      );

      final updatedMemory = _editableMemory.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
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
            content: Text('Error updating memory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Create a new memory (Create mode)
  /*Future<void> _createMemory() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      /*final memoryJson = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "addTags": _addTags,
      };*/

      //final filesToUpload = _newFiles.isNotEmpty ? _newFiles : null;

      // IMPLEMENTAR
      /*await _service.createMemory(
        memoryJson: memoryJson,
        files: filesToUpload,
      );*/

      if (mounted) {
        Navigator.pop(context, true); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating memory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }*/

  // Delete memory (View mode)
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isEditMode = _mode == MemoryMode.edit;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: isEditMode ? "Vista Previa" : "Recuerdo",
        onBack: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isEditMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Yo",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${_editableMemory.createdDate.day.toString().padLeft(2, '0')}/${_editableMemory.createdDate.month.toString().padLeft(2, '0')}/${_editableMemory.createdDate.year}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "edit") {
                          _switchToEditMode();
                        } else if (value == "delete") {
                          _deleteMemory();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: const [
                              Icon(Icons.edit, color: Colors.black),
                              SizedBox(width: 8),
                              Text("Editar", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.black),
                              SizedBox(width: 8),
                              Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Contenido de una Memoria
            Expanded(
              child: SingleChildScrollView(
                child: MemoryContainer(
                  edit: isEditMode,
                  existingFiles: _existingFiles,
                  memory: _editableMemory,
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  screenHeight: screenHeight,
                  onFileChanged: (action, [index, file]) {
                    if (action == "add" && file != null) {
                      setState(() => _newFiles.add(io.File(file.url)));
                    } else if (action == "update" && index != null && file != null) {
                      final ioFile = io.File(file.url);
                      if (index < _newFiles.length) {
                        setState(() => _newFiles[index] = ioFile);
                      } else {
                        setState(() => _newFiles.add(ioFile));
                      }
                    } else if (action == "delete" && index != null) {
                      final deletedFile = _existingFiles[index];
                      setState(() {
                        _deletedFiles.add(deletedFile);
                        _existingFiles.removeAt(index);
                      });
                    }
                  },
                ),
              ),
            ),

            // Botones en modo edición
            if (isEditMode)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.inactive, width: 1),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: "Cancelar",
                            isOutlined: true,
                            textColor: AppColors.primary,
                            onPressed: _cancelEdit,
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
              ),
          ],
        ),
      ),
    );
  }
}