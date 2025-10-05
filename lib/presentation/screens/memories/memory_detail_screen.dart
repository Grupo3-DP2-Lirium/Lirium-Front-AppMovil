// screens/memories/memory_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_container.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_created_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/memory.dart';
import '../../components/buttons/switch_button.dart';

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

  File? _tempFile;

  bool _addTags = false;
  bool _isLoading = false;


  late Memory _memory;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
    _titleController = TextEditingController(text: _memory.title);
    _descriptionController = TextEditingController(text: _memory.description);
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
      // Construir el JSON que espera el backend
      final memoryJson = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "addTags": _addTags,
      };

      // Llamar al servicio de actualización con archivo si existe
      final updated = await _service.updateMemory(
        memoryId: widget.memory.id,
        memoryJson: memoryJson,
        // files: _tempFile != null ? [_tempFile!] : null,
      );

      if (mounted) {
        // Redirigir al grid de memorias y eliminar pantallas anteriores
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MemoryCreatedScreen(memory: _memory,)),
              (route) => false,
        );

        // Si quieres, también puedes actualizar memoria local aquí
        /*
      setState(() {
        widget.memory = widget.memory.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          files: _tempFile != null
              ? [
                  File(
                    id: widget.memory.files.isNotEmpty
                        ? widget.memory.files.first.id
                        : '',
                    url: _tempFile!.path,
                    name: _tempFile!.name,
                    type: _tempFile!.type,
                    mimeType: _tempFile!.mimeType,
                    size: _tempFile!.size,
                    uploadedDate: _tempFile!.uploadedDate,
                    originalName: _tempFile!.originalName,
                  )
                ]
              : widget.memory.files,
        );
      });
      */
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
                  currentFile: _tempFile,
                  onFileChanged: (newFile) {
                    if (newFile != null) {
                      setState(() {
                        _tempFile = newFile;
                      });
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
                  // Switch con líneas arriba y abajo
                  Container(
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
                  ),

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