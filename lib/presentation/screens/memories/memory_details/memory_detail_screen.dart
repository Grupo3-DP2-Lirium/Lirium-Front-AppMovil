import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_create_request.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/enums/memory_origin_type.dart';
import 'package:flutter_frontend/presentation/components/buttons/pop_menu_button.dart';
import 'package:flutter_frontend/presentation/components/cards/header_memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memories_grid_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_controllers.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_container.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/memory.dart';
import 'dart:io' as io;

// Modes: view or edit or create
enum MemoryMode {view, edit, create}

class MemoryDetailScreen extends StatefulWidget {
  final Memory? memory; // Memory data (can be null for new memory)
  final MemoryMode mode; // Current screen mode (view or edit)
  final String? memorialId;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.mode = MemoryMode.view, // Default mode is view
    this.memorialId,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final _service = MemoryService();

  // Controllers for editing metadata and form
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateController _photoController;
  late LocationController _locationController;

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
    (_memoryContainerKey.currentState as dynamic)?.setEditMode(true);
    setState(() => _mode = MemoryMode.edit);
  }

  // Cancel the edit mode and restore the original data
  void _cancelEdit() {
    if (_hasChanges()) {
      appPopupButtonDefault(
        context: context,
        title: "¿Estás seguro?",
        message: "Tienes cambios no guardados. Si cancelas, perderás los cambios.",
        buttons: [
          AppPopupButton(
            text: "Confirmar",
            onPressed: () {
              Navigator.pop(context);
              _resetToOriginalState();
            },
          ),
        ],
      );
    } else {
      _resetToOriginalState();
    }
  }

  void _resetToOriginalState() {
    final containerState = _memoryContainerKey.currentState as dynamic;
    containerState?.setEditMode(false);
    containerState?.restoreOriginalFiles(_originalMemory.files);

    // Restore editable data to its original state
    _editableMemory = _originalMemory.copyWith();
    _existingFiles = List.from(_originalMemory.files);
    _newFiles.clear();
    _deletedFiles.clear();
    _titleController.text = _originalMemory.title;
    _descriptionController.text = _originalMemory.description;

    if (_originalMemory.photoDate != null) {
      _photoController.setDate(_originalMemory.photoDate!);
    } else {
      _photoController.clear();
    }

    if (_originalMemory.latitude != null && _originalMemory.longitude != null) {
      _locationController.setLocation(
        address: _originalMemory.location ?? '',
        lat: _originalMemory.latitude!,
        lon: _originalMemory.longitude!,
      );
      _locationController.fetchAddressFromLatLon();
    } else {
      _locationController.clear();
    }

    setState(() => _mode = MemoryMode.view);
  }

  bool _hasChanges() {
    return _titleController.text != _originalMemory.title ||
        _descriptionController.text != _originalMemory.description ||
        _editableMemory.location != _originalMemory.location ||
        _newFiles.isNotEmpty || _deletedFiles.isNotEmpty;
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
        updateDate: null,
      );
      _editableMemory = _originalMemory.copyWith();
    }

    // Initialize lists with current memory data
    _existingFiles = List.from(_editableMemory.files);
    _titleController = TextEditingController(text: _editableMemory.title);
    _descriptionController = TextEditingController(text: _editableMemory.description);
    _photoController = DateController(
      date: _editableMemory.photoDate,
    );
    _locationController = LocationController(
      latitude: _editableMemory.latitude,
      longitude: _editableMemory.longitude,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Services
  // Save Service
  Future<void> _saveChanges() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Pop-up de Cargando
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    try {
      final memoryJson = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "latitude": _locationController.latitude,
        "longitude": _locationController.longitude,
        "photoDate": _photoController.date?.toIso8601String(),
        "addTags": false,
      };

      final filesToUpload = _newFiles.isNotEmpty ? _newFiles : null;
      final filesToDelete = _deletedFiles
          .map((f) => {"id": f.id, "path": f.url})
          .toList();

      print('filesToUpload es nulo? ${filesToUpload == null}');
      print('filesToUpload tiene elementos? ${filesToUpload?.length ?? 0}');
      print('filesToUpload: $filesToUpload');

      print('filesToDelete es nulo? ${filesToDelete == null}');
      print('filesToDelete tiene elementos? ${filesToDelete.length}');
      print('filesToDelete: $filesToDelete');

      // Llamar al servicio para actualizar memoria
      await _service.updateMemory(
        memoryId: widget.memory!.id,
        memoryJson: memoryJson,
        files: filesToUpload,
        filesToDelete: filesToDelete,
      );

      // Actualizar _editableMemory
      _editableMemory = _editableMemory.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoDate: _photoController.date,
        latitude: _locationController.latitude,
        longitude: _locationController.longitude,
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
        } else if (['mp3', 'm4a', 'wav', 'aac', 'ogg'].contains(ext)) {
          type = 'audio';
          mimeType = 'audio/$ext';
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
        photoDate: _photoController.date,
        latitude: _locationController.latitude,
        longitude: _locationController.longitude,
        files: [...remainingExistingFiles, ...newFilesAsMemoryFiles],
      );

      // Limpiar listas temporales de edición
      _existingFiles = List.from(_originalMemory.files);
      _newFiles.clear();
      _deletedFiles.clear();

      Navigator.pop(context);

      // Mostrar pop-up de éxito
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
    } catch (e, stackTrace) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error al guardar: $e');
      print(stackTrace);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Create a new memory (Create mode)
  Future<void> _createMemory() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Mostrar popup de carga
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    try {
      final request = MemoryCreateRequest(
        memorialId: widget.memorialId!,
        type: MemoryOriginType.spontaneous,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoDate: _photoController.date!,
        latitude: _locationController.latitude,
        longitude: _locationController.longitude,
      );

      final filesToUpload = _newFiles.isNotEmpty ? _newFiles : null;

      final createdMemory = await _service.createMemory(
        request: request,
        files: filesToUpload,
      );

      print("📦 Memory creada con ID: ${createdMemory.idMemory}");

      // Construir archivos locales
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
        } else if (['mp3', 'm4a', 'wav', 'aac', 'ogg'].contains(ext)) {
          type = 'audio';
          mimeType = 'audio/$ext';
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

      // Actualizar el memory original con los files nuevos
      _originalMemory = _originalMemory.copyWith(
        id: createdMemory.idMemory,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        files: newFilesAsMemoryFiles,
        photoDate: _photoController.date,
        latitude: _locationController.latitude,
        longitude: _locationController.longitude,
      );

      // Actualizar provider
      final provider = Provider.of<MemoryProvider>(context, listen: false);
      provider.agregarMemoria(_originalMemory);

      // Limpiar estado local
      _existingFiles = List.from(_originalMemory.files);
      _newFiles.clear();
      _deletedFiles.clear();

      Navigator.pop(context); // Cerrar popup de carga

      // Mostrar popup de éxito
      await appPopupButtonDefault(
        context: context,
        title: "Tu recuerdo ha sido creado",
        message: "Gracias por compartir un momento más de tu historia",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context); // cerrar el popup
              Navigator.pop(context); // retrocede al grid
              Navigator.pop(context);
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar popup de carga si falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear memoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            // Primero cerrar el diálogo de confirmación
            Navigator.pop(context);
            
            // Mostrar indicador de carga
            setState(() => _isLoading = true);
            
            try {
              // Llamar al servicio para eliminar la memoria
              await _service.deleteMemory(widget.memory!.id);

              if (mounted) {
                setState(() => _isLoading = false);
                print('🗑️ Memoria eliminada exitosamente, cerrando pantalla con result=true');
                // Cerrar la pantalla de detalles y devolver true
                Navigator.pop(context, true);
              }
            } catch (e) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
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
    final bool isCreateMode = _mode == MemoryMode.create;
    final bool isViewMode = _mode == MemoryMode.view;

    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: isCreateMode
            ? "Nuevo Recuerdo"
            : isEditMode
            ? "Vista Previa"
            : "Recuerdo",
        onBack: () => Navigator.pop(context),
        appBarHeight: appBarHeight,
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display header and action menu in view mode
            if (isViewMode)
              Padding(
                padding: const EdgeInsets.all(0),
                child: HeaderWithActions(
                  userName: "Yo",
                  createdDate: _editableMemory.createdDate,
                  menuOptions: [
                    PopupMenuOption(
                      label: "Editar",
                      icon: Icons.edit,
                      onTap: () {
                        _switchToEditMode();
                      },
                    ),
                    PopupMenuOption(
                      label: "Eliminar",
                      icon: Icons.delete,
                      onTap: () {
                        _deleteMemory();
                      },
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
                  create: isCreateMode,
                  existingFiles: _existingFiles,
                  memory: _editableMemory,  // Current memory to display/edit
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  photoDateController: _photoController,
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

            // Action button in create mode
            if (isCreateMode)
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
                          child: PrimaryButton(
                            text: "Crear",
                            onPressed: _createMemory,
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