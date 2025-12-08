import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:video_player/video_player.dart';
import '../../../../../../data/models/reflection_model.dart';
import '../widget/audio_player.dart';
import '../widget/image_screen.dart';
import '../widget/video_player.dart';

class AttachmentsPreview extends StatelessWidget {
  final List<ReflectionFile> attachedFiles;
  final Map<String, VideoPlayerController> videoControllers;

  final void Function(int index) onRemove;
  final void Function(ReflectionFile file) onOpen;
  final Set<String> uploadingFiles; // paths o ids

  const AttachmentsPreview({
    super.key,
    required this.attachedFiles,
    required this.videoControllers,
    required this.onRemove,
    required this.onOpen,
    required this.uploadingFiles
  });

  void _showSmallPreview(BuildContext context, ReflectionFile file) {
    if (file.isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FullScreenImage(file: file)),
      );
    } else if (file.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FullScreenVideoPlayer(file: file)),
      );
    } else if (file.isAudio) {
      showModalBottomSheet(
        context: context,
        builder: (_) => AudioPlayerWidget(
          path: file.localPath ?? file.downloadUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archivos adjuntos (${attachedFiles.length})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // --- Archivos normales ---
            ...attachedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _buildAttachmentTile(
                context: context,
                index: index,
                file: file,
              );
            }).toList(),

            // --- Archivos que se están subiendo ---
            ...uploadingFiles.map((path) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.inactive,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingTile() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFileContent(ReflectionFile file) {
    if (file.isImage) return _buildImagePreview(file);
    if (file.isAudio) return _buildAudioPreview();
    return _buildVideoPreview(file);
  }

  Widget _buildImagePreview(ReflectionFile file) {
    if (file.localPath != null) {
      return Image.file(
        File(file.localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
      );
    }

    if (file.downloadUrl.isNotEmpty) {
      return Image.network(
        file.downloadUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
      );
    }

    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      color: Colors.blue.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.audiotrack, size: 24, color: Colors.blue.shade600),
          const SizedBox(height: 4),
          Text(
            "Audio",
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(ReflectionFile file) {
    final path = file.localPath;

    if (path == null) {
      return Container(
        color: Colors.purple.shade50,
        child: const Center(child: Icon(Icons.videocam)),
      );
    }

    final controller = videoControllers[path];

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.purple.shade50,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildAttachmentTile({
    required BuildContext context,
    required int index,
    required ReflectionFile file,
  }) {
    return GestureDetector(
      onTap: () => _showSmallPreview(context, file),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox.expand(
                child: _buildFileContent(file),
              ),
            ),

            // boton borrar
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => onRemove(index),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
