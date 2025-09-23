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

  // Constructor factory para crear desde MemoryResponse
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
    List<String> types = [];
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
          // Mostrar iconos según los tipos de media
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Determinar si el texto necesita ser truncado
    final needsTruncation = subtitle.length > maxDescriptionLength;
    final displayText = needsTruncation
        ? '${subtitle.substring(0, maxDescriptionLength)}...'
        : subtitle;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y media indicator
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
                  if (mediaCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildMediaIndicator(),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Fecha
              Text(
                time,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),

                // Layout con imagen y texto
                if (thumbnailUrl != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vista previa de la imagen
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            thumbnailUrl!,
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
                                  size: 32,
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
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Texto de descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayText,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 3,
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
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Solo texto sin imagen
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
