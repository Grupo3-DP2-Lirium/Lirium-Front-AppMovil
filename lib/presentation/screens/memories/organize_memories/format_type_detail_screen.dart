import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_detail_screen.dart';

class FormatTypeDetailScreen extends StatelessWidget {
  final String title;
  final List<MemoryResponse> memories;
  final Color color;

  const FormatTypeDetailScreen({
    Key? key,
    required this.title,
    required this.memories,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildContent(context),
          ),
          // Botón Crear Recuerdo
          /*Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crear Recuerdo - Próximamente')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Crear Recuerdo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (title.toLowerCase() == 'fotos') {
      return _buildPhotosGrid(context);
    } else if (title.toLowerCase() == 'videos') {
      return _buildVideosList(context);
    } else if (title.toLowerCase() == 'audios') {
      return _buildAudiosList(context);
    } else {
      return _buildLettersList(context);
    }
  }

  // ============ FOTOS - MOSTRAR TODAS LAS FOTOS ============
  Widget _buildPhotosGrid(BuildContext context) {
    // Crear lista de tuplas (memoria, archivo de foto)
    final List<({MemoryResponse memory, dynamic file})> allPhotos = [];

    for (final memory in memories) {
      for (final file in memory.files) {
        if (file.isImage) {
          allPhotos.add((memory: memory, file: file));
        }
      }
    }

    if (allPhotos.isEmpty) {
      return const Center(child: Text('No hay fotos disponibles'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: allPhotos.length,
      itemBuilder: (context, index) {
        final item = allPhotos[index];

        return GestureDetector(
          onTap: () => _navigateToMemoryDetail(context, item.memory),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.file.downloadUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 32),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============ VIDEOS - MOSTRAR TODOS LOS VIDEOS ============
  Widget _buildVideosList(BuildContext context) {
    // Crear lista de tuplas (memoria, archivo de video)
    final List<({MemoryResponse memory, dynamic file})> allVideos = [];

    for (final memory in memories) {
      for (final file in memory.files) {
        if (file.isVideo) {
          allVideos.add((memory: memory, file: file));
        }
      }
    }

    if (allVideos.isEmpty) {
      return const Center(child: Text('No hay videos disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allVideos.length,
      itemBuilder: (context, index) {
        final item = allVideos[index];

        return GestureDetector(
          onTap: () => _navigateToMemoryDetail(context, item.memory),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_circle_outline, color: Colors.green, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.memory.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.memory.description.isNotEmpty)
                        Text(
                          item.memory.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(item.memory.createdDate),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ AUDIOS - MOSTRAR TODOS LOS AUDIOS ============
  Widget _buildAudiosList(BuildContext context) {
    // Crear lista de tuplas (memoria, archivo de audio)
    final List<({MemoryResponse memory, dynamic file})> allAudios = [];

    for (final memory in memories) {
      for (final file in memory.files) {
        if (file.fileType == 'audio') {
          allAudios.add((memory: memory, file: file));
        }
      }
    }

    if (allAudios.isEmpty) {
      return const Center(child: Text('No hay audios disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allAudios.length,
      itemBuilder: (context, index) {
        final item = allAudios[index];

        return GestureDetector(
          onTap: () => _navigateToMemoryDetail(context, item.memory),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.memory.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.memory.description.isNotEmpty)
                        Text(
                          item.memory.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(item.memory.createdDate),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ CARTAS ============
  Widget _buildLettersList(BuildContext context) {
    if (memories.isEmpty) {
      return const Center(child: Text('No hay cartas disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];

        return GestureDetector(
          onTap: () => _navigateToMemoryDetail(context, memory),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mail, color: Colors.purple, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (memory.description.isNotEmpty)
                        Text(
                          memory.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(memory.createdDate),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ NAVEGACIÓN AL DETALLE ============
  void _navigateToMemoryDetail(BuildContext context, MemoryResponse memory) {
    // Convertir MemoryResponse a Memory entity
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}