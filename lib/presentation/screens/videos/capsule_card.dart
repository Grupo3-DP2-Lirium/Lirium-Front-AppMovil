import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';

class CapsuleCard extends StatelessWidget {
  final CapsuleModel capsule;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const CapsuleCard({
    super.key,
    required this.capsule,
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
            // Thumbnail vertical (9:16 aspect ratio)
            Container(
              height: 100,
              width: 56, // 9:16 = 56:100
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _buildThumbnail(),
            ),
            const SizedBox(width: 12),

            // Info de la cápsula
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capsule.title,
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
                    capsule.memorialName,
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
                        '${capsule.totalMemories ?? 0} recuerdos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (capsule.isCompleted || capsule.isPublished) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          capsule.durationFormatted,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Filtro aplicado
                  if (capsule.isCompleted || capsule.isPublished) ...[
                    Row(
                      children: [
                        Icon(Icons.filter_vintage, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          capsule.filterText,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
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

                if (capsule.isProcessing && onCancel != null) {
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
    if ((capsule.isCompleted || capsule.isPublished) && capsule.videoUrl != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.purple[300]!, Colors.pink[300]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Icon(Icons.play_circle_filled, size: 28, color: Colors.white),
          // Badge "STORIES" en vertical
          if (capsule.isPublished)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PÚBLICO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    // Procesando
    else if (capsule.isProcessing) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }
    // Error
    else if (capsule.isFailed) {
      return Icon(Icons.error_outline, size: 32, color: Colors.red[300]);
    }
    // Borrador
    else if (capsule.isDraft) {
      return Icon(Icons.video_library_outlined, size: 32, color: Colors.orange[300]);
    }
    // Default
    else {
      return Icon(Icons.video_call_outlined, size: 32, color: Colors.grey[400]);
    }
  }

  Widget _buildStatusWidget() {
    // Procesando
    if (capsule.isProcessing) {
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${capsule.statusText} ${capsule.progress}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: capsule.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
              minHeight: 4,
            ),
          ),
        ],
      );
    }
    // Publicado
    else if (capsule.isPublished) {
      return Row(
        children: [
          Icon(Icons.public, size: 16, color: Colors.green[600]),
          const SizedBox(width: 4),
          Text(
            capsule.statusText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    // Completado
    else if (capsule.isCompleted) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 4),
          Text(
            capsule.statusText,
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
    else if (capsule.isFailed) {
      return Row(
        children: [
          Icon(Icons.error, size: 16, color: Colors.red[600]),
          const SizedBox(width: 4),
          Text(
            capsule.statusText,
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
    else if (capsule.isDraft) {
      return Row(
        children: [
          Icon(Icons.edit_note, size: 16, color: Colors.orange[600]),
          const SizedBox(width: 4),
          Text(
            capsule.statusText,
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
            capsule.statusText,
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