// screens/memories/memory_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/presentation/components/cards/authenticated_image.dart';

/// Pantalla unificada para crear nueva memoria o editar existente
class MemoryFormScreen extends StatefulWidget {
  final MemoryResponse? memory; // null = crear nueva, con valor = editar
  final String jwt;
  final String memorialId; // Solo se usa al crear nueva

  const MemoryFormScreen({
    super.key,
    this.memory,
    required this.jwt,
    this.memorialId = "0EAE29A7-C601-4BB2-931D-3ADBB3E04E55",
  });

  // Factory para crear nueva memoria
  factory MemoryFormScreen.create({
    required String jwt,
    required String memorialId,
  }) {
    return MemoryFormScreen(
      jwt: jwt,
      memorialId: memorialId,
    );
  }

  // Factory para editar memoria existente
  factory MemoryFormScreen.edit({
    required MemoryResponse memory,
    required String jwt,
  }) {
    return MemoryFormScreen(
      memory: memory,
      jwt: jwt,
    );
  }

  @override
  State<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends State<MemoryFormScreen> {
  final _service = MemoryService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _isEditing = false;
  bool _isLoading = false;

  // Para vista de detalle (cuando memory != null y !isEditing)
  bool get _isViewMode => widget.memory != null && !_isEditing;
  bool get _isEditMode => widget.memory != null && _isEditing;
  bool get _isCreateMode => widget.memory == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.memory?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.memory?.description ?? '',
    );

    // Si es crear nueva, ya está en modo edición
    if (_isCreateMode) {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const meses = [
      '', 'enero','febrero','marzo','abril','mayo','junio',
      'julio','agosto','septiembre','octubre','noviembre','diciembre'
    ];
    return '${date.day} de ${meses[date.month]} de ${date.year}';
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y descripción')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isCreateMode) {
        // Crear nueva memoria
        final memoryJson = {
          "memorialId": widget.memorialId,
          "title": title,
          "description": desc,
          "photoDate": DateTime.now().toIso8601String().split('T').first,
          "location": "Lima, Perú",
          "visible": true,
          "tags": <String>[],
          "type": "SPONTANEOUS",
          "associatedQuestion": null,
          "questionId": null,
          "answerId": null
        };

        final result = await _service.createPersonalMemory(
          token: widget.jwt,
          memoryJson: memoryJson,
          files: null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Memoria creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, result);
        }
      } else {
        // Actualizar memoria existente
        // TODO: Implementar updateMemory en MemoryService
        // await _service.updateMemory(
        //   token: widget.jwt,
        //   memoryId: widget.memory!.idMemory,
        //   title: title,
        //   description: desc,
        // );

        setState(() => _isEditing = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Memoria actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta memoria? '
              'Esta acción no se puede deshacer.',
        ),
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
      // TODO: Implementar deleteMemory en MemoryService
      // await _service.deleteMemory(
      //   token: widget.jwt,
      //   memoryId: widget.memory!.idMemory,
      // );

      if (mounted) {
        Navigator.pop(context, true);
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

  Widget _buildMediaGrid() {
    if (widget.memory == null || widget.memory!.files.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaFiles = widget.memory!.files;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Archivos (${mediaFiles.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: mediaFiles.length,
          itemBuilder: (context, index) {
            final file = mediaFiles[index];

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: file.isImage
                    ? AuthenticatedImage(
                  imageUrl: file.downloadUrl,
                  fit: BoxFit.cover,
                )
                    : Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        file.icon,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file.originalFileName,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShortcutBar() {
    if (!_isEditing) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE7E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Cámara',
                icon: const Icon(Icons.photo_camera_outlined),
                onPressed: () {/* TODO: abrir cámara */},
              ),
              IconButton(
                tooltip: 'Audio',
                icon: const Icon(Icons.mic_none_outlined),
                onPressed: () {/* TODO: grabar audio */},
              ),
              IconButton(
                tooltip: 'Galería',
                icon: const Icon(Icons.image_outlined),
                onPressed: () {/* TODO: abrir galería */},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isViewMode) ...[
            // Modo vista: botones de editar y menú
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _deleteMemory();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Modo edición/creación: botones cancelar y guardar
            if (_isEditMode)
              TextButton(
                onPressed: () {
                  setState(() => _isEditing = false);
                  _titleController.text = widget.memory!.title;
                  _descriptionController.text = widget.memory!.description;
                },
                child: const Text('Cancelar'),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(
                  Icons.check_circle,
                  color: theme.primaryColor,
                  size: 28,
                ),
                tooltip: 'Guardar',
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              _isEditing ? 96 : 16, // Espacio para la barra de atajos
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha (solo en modo vista o edición)
                if (!_isCreateMode) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(
                        widget.memory!.photoDate ?? widget.memory!.createdDate,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Título
                if (_isEditing) ...[
                  TextField(
                    controller: _titleController,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                ] else ...[
                  Text(
                    widget.memory!.title.isEmpty
                        ? 'Sin título'
                        : widget.memory!.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.memory!.title.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Descripción
                if (_isEditing) ...[
                  TextField(
                    controller: _descriptionController,
                    style: textTheme.bodyLarge?.copyWith(height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'Empezar a escribir...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 8,
                  ),
                ] else ...[
                  Text(
                    widget.memory!.description.isEmpty
                        ? 'Sin descripción'
                        : widget.memory!.description,
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: widget.memory!.description.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],

                // Grid de archivos multimedia
                _buildMediaGrid(),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Barra de atajos (solo en modo edición)
          _buildShortcutBar(),
        ],
      ),
    );
  }
}