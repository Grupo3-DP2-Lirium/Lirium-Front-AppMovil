import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:provider/provider.dart';

class FileTypeFilterButton extends StatelessWidget {
  const FileTypeFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.watch<MemoryProvider>();
    final hasFilter = memoryProvider.tipoArchivoFiltro != null;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: hasFilter ? AppColors.primary : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: hasFilter
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showFileTypeSelector(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFilterIcon(memoryProvider.tipoArchivoFiltro),
                  color: hasFilter ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getFilterText(memoryProvider.tipoArchivoFiltro),
                  style: TextStyle(
                    color: hasFilter ? Colors.white : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      context.read<MemoryProvider>().limpiarFiltroTipoArchivo();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(String? tipo) {
    switch (tipo) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.filter_alt;
    }
  }

  String _getFilterText(String? tipo) {
    switch (tipo) {
      case 'image':
        return 'Imágenes';
      case 'video':
        return 'Videos';
      case 'audio':
        return 'Audios';
      case 'text':
        return 'Textos';
      default:
        return 'Tipo';
    }
  }

  void _showFileTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FileTypeSelectorModal(),
    );
  }
}

class _FileTypeSelectorModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.read<MemoryProvider>();
    final currentFilter = memoryProvider.tipoArchivoFiltro;

    final fileTypes = [
      {
        'id': null,
        'name': 'Todos los tipos',
        'icon': Icons.all_inclusive,
        'description': 'Ver todos los recuerdos',
      },
      {
        'id': 'image',
        'name': 'Imágenes',
        'icon': Icons.image,
        'description': 'Solo fotos e imágenes',
      },
      {
        'id': 'video',
        'name': 'Videos',
        'icon': Icons.videocam,
        'description': 'Solo videos y grabaciones',
      },
      {
        'id': 'audio',
        'name': 'Audios',
        'icon': Icons.audiotrack,
        'description': 'Solo audios y música',
      },
      {
        'id': 'text',
        'name': 'Textos',
        'icon': Icons.text_fields,
        'description': 'Solo recuerdos de texto',
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filtrar por tipo de archivo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (currentFilter != null)
                  TextButton(
                    onPressed: () {
                      memoryProvider.limpiarFiltroTipoArchivo();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Limpiar',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),

          // Lista de tipos de archivo
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: fileTypes.length,
              itemBuilder: (context, index) {
                final fileType = fileTypes[index];
                final isSelected = currentFilter == fileType['id'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 1)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        fileType['icon'] as IconData,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      fileType['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      fileType['description'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.7)
                            : Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      memoryProvider.filtrarPorTipoArchivo(
                        fileType['id'] as String?,
                      );
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
