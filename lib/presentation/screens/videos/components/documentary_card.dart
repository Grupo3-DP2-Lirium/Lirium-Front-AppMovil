import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/documentary_model.dart';

class DocumentaryCard extends StatelessWidget {
  final DocumentaryModel documentary;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const DocumentaryCard({
    super.key,
    required this.documentary,
    required this.onTap,
    this.onDelete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail o icono
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _buildThumbnail(),
            ),
            const SizedBox(width: 12),

            // Info del documental
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentary.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Text(
                    documentary.memorialName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Info: memorias y duración
                  Row(
                    children: [
                      Icon(Icons.photo_library, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${documentary.totalMemories} recuerdos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (documentary.isCompleted || documentary.isPublished) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          documentary.durationFormatted,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Estado
                  _buildStatusWidget(),
                ],
              ),
            ),

            // Menú de opciones
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (value) {
                if (value == 'delete' && onDelete != null) {
                  onDelete!();
                } else if (value == 'cancel' && onCancel != null) {
                  onCancel!();
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuEntry<String>>[];

                if (documentary.isProcessing && onCancel != null) {
                  items.add(
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 18, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Cancelar'),
                        ],
                      ),
                    ),
                  );
                }

                if (onDelete != null) {
                  items.add(
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  );
                }

                return items;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    // Publicado o Completado con video
    if ((documentary.isCompleted || documentary.isPublished) && documentary.videoUrl != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.purple[300]!, Colors.blue[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Icon(Icons.play_circle_filled, size: 32, color: Colors.white),
          // Badge si está publicado
          if (documentary.isPublished)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PÚBLICO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    // Procesando
    else if (documentary.isProcessing) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
          ),
          const CircularProgressIndicator(strokeWidth: 3),
        ],
      );
    }
    // Error
    else if (documentary.isFailed) {
      return Icon(Icons.error_outline, size: 40, color: Colors.red[300]);
    }
    // Borrador
    else if (documentary.isDraft) {
      return Icon(Icons.edit_note, size: 40, color: Colors.orange[300]);
    }
    // Default
    else {
      return Icon(Icons.movie_outlined, size: 40, color: Colors.grey[400]);
    }
  }

  Widget _buildStatusWidget() {
    // Procesando
    if (documentary.isProcessing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${documentary.statusText} ${documentary.progress}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: documentary.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              minHeight: 4,
            ),
          ),
        ],
      );
    }
    // Publicado
    else if (documentary.isPublished) {
      return Row(
        children: [
          Icon(Icons.public, size: 16, color: Colors.green[600]),
          const SizedBox(width: 4),
          Text(
            documentary.statusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    // Completado (listo para publicar)
    else if (documentary.isCompleted) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 4),
          Text(
            documentary.statusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    // Error
    else if (documentary.isFailed) {
      return Row(
        children: [
          Icon(Icons.error, size: 16, color: Colors.red[600]),
          const SizedBox(width: 4),
          Text(
            documentary.statusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    // Borrador
    else if (documentary.isDraft) {
      return Row(
        children: [
          Icon(Icons.edit_note, size: 16, color: Colors.orange[600]),
          const SizedBox(width: 4),
          Text(
            documentary.statusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    // Default
    else {
      return Row(
        children: [
          Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            documentary.statusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }
}