import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:intl/intl.dart';

class MemoryCard extends StatelessWidget {
  final MemoryResponse memory;
  final VoidCallback? onTap;

  const MemoryCard({
    Key? key,
    required this.memory,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal o placeholder
            Expanded(
              flex: 3,
              child: _buildImageSection(),
            ),
            
            // Información del recuerdo
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      memory.title.isNotEmpty ? memory.title : 'Sin título',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Fecha
                    if (memory.photoDate != null)
                      Text(
                        DateFormat('dd/MM/yyyy').format(memory.photoDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Indicadores de archivos
                    _buildFileIndicators(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    // Buscar la primera imagen en los archivos
    final imageFile = memory.files.isNotEmpty 
        ? memory.files.firstWhere(
            (file) => file.fileType == 'image',
            orElse: () => memory.files.first,
          )
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: imageFile?.fileUrl != null
            ? Image.network(
                imageFile!.downloadUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  print('Image URL: ${imageFile!.downloadUrl}');
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    IconData icon;
    Color color;

    // Determinar icono basado en el tipo de memoria
    if (memory.files.any((file) => file.fileType == 'image')) {
      icon = Icons.photo;
      color = Colors.blue;
    } else if (memory.files.any((file) => file.fileType == 'video')) {
      icon = Icons.videocam;
      color = Colors.red;
    } else if (memory.files.any((file) => file.fileType == 'audio')) {
      icon = Icons.audiotrack;
      color = Colors.green;
    } else {
      icon = Icons.description;
      color = Colors.orange;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withOpacity(0.1),
      child: Icon(
        icon,
        size: 40,
        color: color,
      ),
    );
  }

  Widget _buildFileIndicators() {
    if (memory.files.isEmpty) {
      return const SizedBox.shrink();
    }

    // Contar tipos de archivos
    int imageCount = memory.files.where((f) => f.fileType == 'image').length;
    int videoCount = memory.files.where((f) => f.fileType == 'video').length;
    int audioCount = memory.files.where((f) => f.fileType == 'audio').length;

    List<Widget> indicators = [];

    if (imageCount > 0) {
      indicators.add(_buildIndicator(Icons.photo, imageCount, Colors.blue));
    }
    if (videoCount > 0) {
      indicators.add(_buildIndicator(Icons.videocam, videoCount, Colors.red));
    }
    if (audioCount > 0) {
      indicators.add(_buildIndicator(Icons.audiotrack, audioCount, Colors.green));
    }

    if (indicators.isEmpty) return const SizedBox.shrink();

    return Row(
      children: indicators
          .expand((widget) => [widget, const SizedBox(width: 8)])
          .take(indicators.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildIndicator(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}