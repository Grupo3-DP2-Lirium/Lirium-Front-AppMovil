// screens/memories/memory_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/utils/file_url_helper.dart';

class MemoryDetailScreen extends StatefulWidget {
  final MemoryResponse memory;
  final String jwt;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    required this.jwt,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final _service = MemoryService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memory.title);
    _descriptionController = TextEditingController(text: widget.memory.description);
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

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar el método updateMemory en tu MemoryService
      // await _service.updateMemory(
      //   token: widget.jwt,
      //   memoryId: widget.memory.idMemory,
      //   title: _titleController.text.trim(),
      //   description: _descriptionController.text.trim(),
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
      // TODO: Implementar el método deleteMemory en tu MemoryService
      // await _service.deleteMemory(
      //   token: widget.jwt,
      //   memoryId: widget.memory.idMemory,
      // );

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

  Widget _buildMediaGrid() {
    final mediaFiles = widget.memory.files;

    if (mediaFiles.isEmpty) return const SizedBox.shrink();

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
                    ? _buildImageWidget(file)
                    : _buildNonImageWidget(file),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageWidget(FileResponse file) {
    return Image.network(
      file.fullUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: 40,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildNonImageWidget(FileResponse file) {
    return Container(
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
          if (!_isEditing) ...[
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
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _titleController.text = widget.memory.title;
                _descriptionController.text = widget.memory.description;
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Guardar'),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha de creación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(widget.memory.photoDate ?? widget.memory.createdDate),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Título
            if (_isEditing) ...[
              TextField(
                controller: _titleController,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Título de la memoria...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ] else ...[
              Text(
                widget.memory.title.isEmpty ? 'Sin título' : widget.memory.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.memory.title.isEmpty ? Colors.grey : Colors.black87,
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
                  hintText: 'Escribe tu reflexión aquí...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 8,
              ),
            ] else ...[
              Text(
                widget.memory.description.isEmpty
                    ? 'Sin descripción'
                    : widget.memory.description,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: widget.memory.description.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ],

            // Imágenes
            _buildMediaGrid(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}