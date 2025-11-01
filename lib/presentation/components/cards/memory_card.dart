import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:video_player/video_player.dart';

import '../common/app_colors.dart';

class MemoryCard extends StatefulWidget {
  final Memory memory;
  final VoidCallback? onTap;
  final bool isGridView;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.isGridView = false,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
  }

  void _initializeVideoIfNeeded() {
    if (widget.memory.files.isEmpty) return;

    final firstFile = widget.memory.files.first;
    final urlLower = firstFile.url.toLowerCase();
    final isVideo = urlLower.endsWith('.mp4') ||
        urlLower.endsWith('.mov') ||
        urlLower.endsWith('.avi');

    if (!isVideo) return;

    if (_videoController != null) return;

    if (firstFile.url.startsWith('http')) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(firstFile.url));
    } else {
      _videoController = VideoPlayerController.file(File(firstFile.url));
    }

    _videoController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _videoController!.setLooping(true);
      _videoController!.pause();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambió la URL del primer archivo, reinicializa el video
    final oldUrl = oldWidget.memory.files.isNotEmpty ? oldWidget.memory.files.first.url : '';
    final newUrl = widget.memory.files.isNotEmpty ? widget.memory.files.first.url : '';

    if (oldUrl != newUrl) {
      _videoController?.dispose();
      _videoController = null;
      _initializeVideoIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: widget.isGridView ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.isGridView ? _buildGridContent() : _buildListContent(),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (widget.memory.files.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Sin archivos", style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    final firstFile = widget.memory.files.first;
    final url = firstFile.url.toLowerCase();

    final isVideo = url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
    final isAudio = url.endsWith('.mp3') || url.endsWith('.wav') || url.endsWith('.m4a') || url.endsWith('.aac');
    final isImage = url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.gif');

    if (isVideo) {
      if (_videoController == null || !_videoController!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ));
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      );
    } else if (isAudio) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Audio", style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    } else if (isImage) {
      final isNetwork = firstFile.url.startsWith('http');

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isNetwork
            ? Image.network(
          firstFile.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.grey),
        )
            : Image.file(
          File(firstFile.url),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    else {
      return const Center(
        child: Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
      );
    }
  }

  Widget _buildGridContent() {
    final DateTime? dateToShow = widget.memory.createdDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildMediaPreview(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.memory.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (dateToShow != null) ...[
          const SizedBox(height: 4),
          Text(
          _formatDate(dateToShow),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.memory.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (widget.memory.photoDate != null)
              Text(
                _formatDate(widget.memory.photoDate!),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        if (widget.memory.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.memory.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
        if (widget.memory.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: _buildMediaPreview(),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
