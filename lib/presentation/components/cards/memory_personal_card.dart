// components/cards/memory_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/utils/file_url_helper.dart';

class MemoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int mediaCount; // Cambiado de imageCount a mediaCount para incluir videos/audio
  final String? thumbnailUrl;
  final List<String> mediaTypes; // Para mostrar qué tipos de archivos tiene
  final VoidCallback onTap;
  final int maxDescriptionLength;

  const MemoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.mediaCount,
    this.thumbnailUrl,
    this.mediaTypes = const [],
    required this.onTap,
    this.maxDescriptionLength = 120,
  });

  factory MemoryCard.fromMemory({
    required MemoryResponse memory,
    required VoidCallback onTap,
    int maxDescriptionLength = 120,
  }) {
    return MemoryCard(
      title: memory.title,
      subtitle: memory.description,
      time: _formatDate(memory.photoDate ?? memory.createdDate),
      mediaCount: memory.mediaCount,
      thumbnailUrl: memory.firstImageUrl,
      mediaTypes: _getMediaTypes(memory),
      onTap: onTap,
      maxDescriptionLength: maxDescriptionLength,
    );
  }

  static List<String> _getMediaTypes(MemoryResponse memory) {
    final types = <String>[];
    if (memory.images.isNotEmpty) types.add('image');
    if (memory.videos.isNotEmpty) types.add('video');
    if (memory.audios.isNotEmpty) types.add('audio');
    return types;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildMediaIndicator() {
    if (mediaCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < mediaTypes.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Icon(
              _getMediaIcon(mediaTypes[i]),
              size: 12,
              color: Colors.blue.shade600,
            ),
          ],
          const SizedBox(width: 4),
          Text(
            '$mediaCount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMediaIcon(String mediaType) {
    switch (mediaType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.attach_file;
    }
  }

  // NUEVO: sección de media debajo de la descripción (estilo Instagram)
  Widget _buildMediaSection() {
    // si no hay imagen ni media, no mostramos nada
    if (thumbnailUrl == null && mediaCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thumbnailUrl != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1, // cuadrado (puedes cambiar a 4/3 o 16/9)
              child: Image.network(
                thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey.shade400, size: 32),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // truncado del texto
    final needsTruncation = subtitle.length > maxDescriptionLength;
    final displayText = needsTruncation
        ? '${subtitle.substring(0, maxDescriptionLength)}...'
        : subtitle;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1), // borde
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header: título + indicador de media (pequeño)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? 'Sin título' : title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // fecha
              Text(
                time,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // descripción (si hay)
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  displayText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (needsTruncation) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],

              // NUEVO: media debajo de la descripción
              _buildMediaSection(),
            ],
          ),
        ),
      ),
    );
  }
}