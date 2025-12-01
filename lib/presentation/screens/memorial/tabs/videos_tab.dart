import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/models/user_lite_response.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/providers/memories_by_memorial_provider.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:provider/provider.dart';

class VideosTab extends StatefulWidget {
  final String memorialId;

  const VideosTab({
    super.key,
    required this.memorialId
  });

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Cargar memorias usando el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MemoriesByMemorialProvider>();
      if (!provider.loaded) {
        provider.loadMemories(memorialId: widget.memorialId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<MemoriesByMemorialProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.memories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // Convertir Memory entities a MemoryResponse
        final memories = provider.memories.map((m) => _memoryToResponse(m)).toList();
        final memoriesWithVideos = memories.where((m) => m.files.any((f) => f.isVideo)).toList();

        if (memoriesWithVideos.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: memoriesWithVideos.length,
          itemBuilder: (context, index) => _buildVideoCard(memoriesWithVideos[index]),
        );
      },
    );
  }

  Widget _buildVideoCard(MemoryResponse memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (memory.files.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
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
                    ),
                  ),
                ),
                // Play overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Video',
                            style: AppColors.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(memory.title, style: AppColors.h6.copyWith(fontSize: 17)),
                if (memory.description != null && memory.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    memory.description!,
                    style: AppColors.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay videos',
              style: AppColors.h5,
            ),
            const SizedBox(height: 8),
            Text(
              'Los videos que agregues aparecerán aquí',
              style: AppColors.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  MemoryResponse _memoryToResponse(Memory memory) {
    return MemoryResponse(
      idMemory: memory.id,
      type: memory.type,
      title: memory.title,
      description: memory.description,
      photoDate: memory.photoDate,
      location: memory.location,
      visible: memory.visible,
      tags: memory.tags,
      associatedQuestion: memory.associatedQuestion,
      files: memory.files.map((f) => FileResponse(
        idFile: f.id,
        fileName: f.name,
        originalFileName: f.originalName,
        fileType: f.type,
        mimeType: f.mimeType,
        fileSize: f.size,
        fileUrl: f.url,
        uploadedDate: f.uploadedDate,
      )).toList(),
      totalUsedSpace: memory.totalUsedSpace,
      createdDate: memory.createdDate,
      updateDate: memory.updateDate,
      latitude: memory.latitude,
      longitude: memory.longitude,
      esLineaTiempo: memory.esLineaTiempo,        // USA EL VALOR DE MEMORY
      categories: memory.categories,               // USA EL VALOR DE MEMORY
      moments: memory.moments,                     // USA EL VALOR DE MEMORY
      author: memory.author != null ? UserLiteResponse(  // USA EL VALOR DE MEMORY
        idUser: memory.author!.id,
        name: memory.author!.name,
        profilePhotoUrl: memory.author!.profilePhotoUrl,
      ) : null,
    );
  }
}