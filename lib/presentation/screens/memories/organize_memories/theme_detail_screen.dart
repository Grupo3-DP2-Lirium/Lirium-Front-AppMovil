import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_detail_screen.dart';

class ThemeDetailScreen extends StatelessWidget {
  final String title;
  final List<MemoryResponse> memories;
  final Color color;
  final IconData icon;

  const ThemeDetailScreen({
    Key? key,
    required this.title,
    required this.memories,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${memories.length} recuerdo${memories.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header con descripción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.1)),
              ),
            ),
            child: Text(
              'Revive los momentos de ${title.toLowerCase()}',
              style: AppColors.bodyMedium.copyWith(
                color: color.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Lista de recuerdos
          Expanded(
            child: memories.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: memories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildMemoryCard(context, memories[index]),
            ),
          ),

          // Botón crear recuerdo
          /*Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crear Recuerdo - Próximamente')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Crear Recuerdo de $title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildMemoryCard(BuildContext context, MemoryResponse memory) {
    final hasImages = memory.files.any((f) => f.isImage);
    final hasVideos = memory.files.any((f) => f.isVideo);
    final hasAudio = memory.files.any((f) => f.fileType == 'audio');
    final isTextOnly = memory.files.isEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToMemoryDetail(context, memory),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Autor + Fecha
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withOpacity(0.1),
                    backgroundImage: memory.author?.profilePhotoUrl != null
                        ? NetworkImage(memory.author!.profilePhotoUrl!)
                        : null,
                    child: memory.author?.profilePhotoUrl == null
                        ? Icon(Icons.person, color: color, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.author?.name ?? 'Usuario',
                          style: AppColors.labelLarge.copyWith(fontSize: 15),
                        ),
                        Text(
                          _formatTimeAgo(memory.createdDate),
                          style: AppColors.labelSmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Badge de categoría
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          title,
                          style: AppColors.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Título y descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (memory.title.isNotEmpty) ...[
                    Text(
                      memory.title,
                      style: AppColors.h6.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (memory.description.isNotEmpty)
                    Text(
                      memory.description,
                      style: AppColors.bodyMedium,
                      maxLines: isTextOnly ? 10 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Media content
            if (hasImages || hasVideos) ...[
              const SizedBox(height: 12),
              _buildMediaGrid(memory.files),
            ],

            // Audio player
            if (hasAudio) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildAudioPlayer(memory.files.firstWhere((f) => f.fileType == 'audio')),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<dynamic> files) {
    final mediaFiles = files.where((f) => f.isImage || f.isVideo).toList();
    if (mediaFiles.isEmpty) return const SizedBox();

    if (mediaFiles.length == 1) {
      return _buildSingleMedia(mediaFiles.first);
    } else if (mediaFiles.length == 2) {
      return _buildDoubleMedia(mediaFiles);
    } else {
      return _buildMultipleMedia(mediaFiles);
    }
  }

  Widget _buildSingleMedia(dynamic file) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (file.isVideo)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[300]!, Colors.pink[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.videocam_rounded, size: 64, color: Colors.white70),
                  ),
                )
              else
                Image.network(
                  file.downloadUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              if (file.isVideo)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleMedia(List<dynamic> files) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildMediaThumbnail(files[0])),
          const SizedBox(width: 4),
          Expanded(child: _buildMediaThumbnail(files[1])),
        ],
      ),
    );
  }

  Widget _buildMultipleMedia(List<dynamic> files) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildMediaThumbnail(files[0])),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                _buildMediaThumbnail(files[1]),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    _buildMediaThumbnail(files[2]),
                    if (files.length > 3)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${files.length - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail(dynamic file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file.isVideo)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.pink[300]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.videocam_rounded, size: 32, color: Colors.white70),
                ),
              )
            else
              Image.network(
                file.downloadUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported, size: 32),
                ),
              ),
            if (file.isVideo)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_filled, size: 32, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(dynamic audioFile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio adjunto',
                  style: AppColors.labelMedium.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  audioFile.originalFileName ?? 'audio.mp3',
                  style: AppColors.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.volume_up_rounded, color: color),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay recuerdos en esta temática',
            style: AppColors.bodyLarge,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(dynamic date) {
    try {
      final dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'Hace ${years} año${years > 1 ? 's' : ''}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'Hace ${months} mes${months > 1 ? 'es' : ''}';
      } else if (difference.inDays > 0) {
        return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Justo ahora';
      }
    } catch (e) {
      return '';
    }
  }

  void _navigateToMemoryDetail(BuildContext context, MemoryResponse memory) {
    final memoryEntity = Memory(
      id: memory.idMemory,
      type: memory.type,
      title: memory.title,
      description: memory.description ?? '',
      photoDate: memory.photoDate != null ? DateTime.parse(memory.photoDate.toString()) : null,
      location: memory.location,
      visible: memory.visible,
      tags: memory.tags ?? [],
      associatedQuestion: memory.associatedQuestion,
      files: memory.files.map((f) => File(
        id: f.idFile,
        name: f.fileName,
        originalName: f.originalFileName,
        type: f.fileType,
        mimeType: f.mimeType,
        size: f.fileSize,
        url: f.fileUrl,
        uploadedDate: f.uploadedDate != null ? DateTime.parse(f.uploadedDate.toString()) : DateTime.now(),
      )).toList(),
      totalUsedSpace: memory.totalUsedSpace,
      createdDate: memory.createdDate != null ? DateTime.parse(memory.createdDate.toString()) : DateTime.now(),
      updateDate: memory.updateDate != null ? DateTime.parse(memory.updateDate.toString()) : null,
      latitude: memory.latitude,
      longitude: memory.longitude,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(
          memory: memoryEntity,
          mode: MemoryMode.view,
        ),
      ),
    );
  }
}