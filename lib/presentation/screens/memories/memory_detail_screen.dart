import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_container.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_created_screen.dart';
import '../../../domain/entities/memory.dart';
import 'dart:io' as io;

// Modes: view or edit
enum MemoryMode {view, edit}

class MemoryDetailScreen extends StatefulWidget {
  final Memory? memory; // Memory data (can be null for new memory)
  final MemoryMode mode; // Current screen mode (view or edit)

  // Constructor: accepts memory and mode
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

  // Controllers for editing metadatos
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _mesController;
  late TextEditingController _ahoController;
  late TextEditingController _locationController;

  // State flags and data
  bool _isLoading = false;
  late Memory _originalMemory; // Original memory object (for reset)
  late Memory _editableMemory; // Editable copy of the memory

  // Lists for managing files (existing, new, and deleted)
  List<File> _existingFiles = [];
  final List<io.File> _newFiles = [];
  final List<File> _deletedFiles = [];

  // Current memory mode (view or edit)
  late MemoryMode _mode;

  // Key for accessing the memory container state
  final GlobalKey _memoryContainerKey = GlobalKey();

  // Switch to edit mode
  void _switchToEditMode() {
    // 1) Notify the container to enter edit mode (without recreating it)
    (_memoryContainerKey.currentState as dynamic)?.setEditMode(true);
    // 2) Update UI (AppBar & buttons)
    setState(() => _mode = MemoryMode.edit);
  }

  // Cancel the edit mode and restore the original data
  void _cancelEdit() {
    // 1) Notify the container to exit edit mode
    final containerState = _memoryContainerKey.currentState as dynamic;
    containerState?.setEditMode(false);
    containerState?.restoreOriginalFiles(_originalMemory.files);

    // 2) Restore editable data to its original state
    _editableMemory = _originalMemory.copyWith();
    _existingFiles = List.from(_originalMemory.files);
    _newFiles.clear();
    _deletedFiles.clear();
    _titleController.text = _originalMemory.title;
    _descriptionController.text = _originalMemory.description;

    // 3) Update UI to view mode (AppBar & buttons)
    setState(() => _mode = MemoryMode.view);
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    if (widget.memory != null) {
      // Edit existing memory (if provided)
      _originalMemory = widget.memory!;
      _editableMemory = _originalMemory.copyWith();
    } else {
      // Initialize for creating new memory
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

    // Initialize lists with current memory data
    _existingFiles = List.from(_editableMemory.files);
    _titleController = TextEditingController(text: _editableMemory.title);
    _descriptionController = TextEditingController(text: _editableMemory.description);
    _mesController = TextEditingController(text: "");
    _ahoController = TextEditingController(text: "");
    _locationController = TextEditingController(text: _editableMemory.location ?? "");
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Services

  Future<void> _saveChanges() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // 1) Mostrar pop-up de loading
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    try {
      // 2) Preparar JSON para enviar al backend
      final memoryJson = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "addTags": false,
      };

      // 3) Archivos a subir
      final filesToUpload = _newFiles.isNotEmpty ? _newFiles : null;

      // 4) Archivos a eliminar
      final filesToDelete = _deletedFiles
          .map((f) => {"id": f.id, "path": f.url})
          .toList();

      // 5) Llamar al servicio para actualizar memoria
      await _service.updateMemory(
        memoryId: widget.memory!.id,
        memoryJson: memoryJson,
        files: filesToUpload,
        filesToDelete: filesToDelete,
      );

      // 6) Actualizar _editableMemory y _originalMemory
      _editableMemory = _editableMemory.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Convertir archivos nuevos a File completos
      final newFilesAsMemoryFiles = _newFiles.map((f) {
        final ext = f.path.split('.').last.toLowerCase();
        String type;
        String mimeType;
        if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
          type = 'image';
          mimeType = 'image/$ext';
        } else if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) {
          type = 'video';
          mimeType = 'video/$ext';
        } else {
          type = 'file';
          mimeType = 'application/octet-stream';
        }
        return File(
          id: "",
          name: f.path.split('/').last,
          originalName: f.path.split('/').last,
          type: type,
          mimeType: mimeType,
          size: 0,
          url: f.path,
          uploadedDate: DateTime.now(),
        );
      }).toList();

      // Filtrar los archivos existentes que NO se eliminaron
      final remainingExistingFiles = _existingFiles.where((f) =>
      !_deletedFiles.any((del) => del.id == f.id)
      ).toList();

      // Actualizar el memory original combinando los archivos restantes + nuevos
      _originalMemory = _originalMemory.copyWith(
        title: _editableMemory.title,
        description: _editableMemory.description,
        files: [...remainingExistingFiles, ...newFilesAsMemoryFiles],
      );

      // Limpiar listas temporales de edición
      _existingFiles = List.from(_originalMemory.files);
      _newFiles.clear();
      _deletedFiles.clear();

      // 7) Cerrar loading
      Navigator.pop(context);

      // 8) Mostrar pop-up de éxito
      await appPopupButtonDefault(
        context: context,
        title: "Tu recuerdo ha sido actualizado",
        message: "Gracias por compartir un momento más de tu historia",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              (_memoryContainerKey.currentState as dynamic)?.setEditMode(false);
              Navigator.pop(context, _originalMemory); // Devuelve el memory actualizado
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // cerrar loading si hay error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
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
    await appPopupButtonDefault(
      context: context,
      title: '¿Eliminar este Recuerdo?',
      message: 'Esta acción no se puede deshacer',
      buttons: [
        AppPopupButton(
          text: 'Cancelar',
          onPressed: () {
            // No hace nada, solo cierra el popup
          },
        ),
        AppPopupButton(
          text: 'Eliminar',
          onPressed: () async {
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
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine if the app is in edit mode
    final bool isEditMode = _mode == MemoryMode.edit;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: isEditMode ? "Vista Previa" : "Recuerdo", // Set title based on mode
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
            // Display header and action menu (edit/delete) in view mode
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
                        // Display formatted date of memory creation
                        Text(
                          "${_editableMemory.createdDate.day.toString().padLeft(2, '0')}/${_editableMemory.createdDate.month.toString().padLeft(2, '0')}/${_editableMemory.createdDate.year}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Popup menu with options to edit or delete
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "edit") {
                          _switchToEditMode(); // Switch to edit mode
                        } else if (value == "delete") {
                          _deleteMemory(); // Delete memory
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

            // Memory content (view/edit mode)
            Expanded(
              child: SingleChildScrollView(
                child: MemoryContainer(
                  key: _memoryContainerKey,
                  edit: isEditMode, // Pass edit mode flag to the container
                  existingFiles: _existingFiles,
                  memory: _editableMemory,  // Current memory to display/edit
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  mesController: _mesController,
                  ahoController: _ahoController,
                  locationController: _locationController,
                  screenHeight: screenHeight,
                  onFileChanged: (action, [index, file]) {
                    // Handle file actions (add, update, delete)
                    if (action == "add" && file != null) {
                      _newFiles.add(io.File(file.url)); // Add new file
                    } else if (action == "update" && index != null && file != null) {
                      final ioFile = io.File(file.url);
                      if (index < _newFiles.length) {
                        _newFiles[index] = ioFile; // Update existing file
                      } else {
                        _newFiles.add(ioFile); // Add new file to list
                      }
                    } else if (action == "delete" && index != null && file != null) {
                      final isExisting = file.id.isNotEmpty;
                      if (isExisting) {
                        _deletedFiles.add(file); // Mark file for deletion
                        _existingFiles.removeWhere((f) => f.id == file.id);
                      } else {
                        _newFiles.removeWhere((f) => f.path == file.url); // Remove from new files
                      }
                    }
                  },
                ),
              ),
            ),

            // Action buttons in edit mode
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
                        // Cancel button
                        Expanded(
                          child: SecondaryButton(
                            text: "Cancelar",
                            isOutlined: true,
                            textColor: AppColors.primary,
                            onPressed: _cancelEdit,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        // Save button
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