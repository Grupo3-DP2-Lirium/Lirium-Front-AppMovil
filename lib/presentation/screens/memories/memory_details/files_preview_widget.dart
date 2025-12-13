import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/file_preview.dart';
import 'package:video_player/video_player.dart';

class PreviewWidget extends StatefulWidget {
  final List<File> localFiles;
  final int currentFileIndex;
  final bool isEditing;
  final Function(int) deleteFile;
  final Function(BuildContext, String, {int? index}) editFile;
  final Function(BuildContext) showAddOptions;
  final double height;
  final Map<Key, VideoPlayerController> videoControllers;

  const PreviewWidget({
    super.key,
    required this.localFiles,
    required this.currentFileIndex,
    required this.isEditing,
    required this.deleteFile,
    required this.editFile,
    required this.showAddOptions,
    required this.height,
    required this.videoControllers,
  });

  @override
  PreviewWidgetState createState() => PreviewWidgetState();
}

class PreviewWidgetState extends State<PreviewWidget> {
  late int currentFileIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    currentFileIndex = widget.currentFileIndex;
    _pageController = PageController(initialPage: currentFileIndex);
  }

  @override
  void didUpdateWidget(covariant PreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si se elimina un archivo y el índice queda fuera de rango
    if (currentFileIndex >= widget.localFiles.length && widget.localFiles.isNotEmpty) {
      currentFileIndex = widget.localFiles.length - 1;
      _pageController.jumpToPage(currentFileIndex);
    } else if (widget.localFiles.isEmpty) {
      currentFileIndex = 0;
    }

    // Si se agrega el primer archivo (la lista estaba vacía antes)
    if (oldWidget.localFiles.isEmpty && widget.localFiles.isNotEmpty) {
      currentFileIndex = 0;
      _pageController = PageController(initialPage: 0);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeVideoController(File file) {
    if (widget.videoControllers.containsKey(file.key) &&
        widget.videoControllers[file.key]!.value.isInitialized) {
      return;
    }

    widget.videoControllers[file.key] = VideoPlayerController.networkUrl(
      Uri.parse(file.url),
    )..initialize().then((_) {
      if (mounted) setState(() {});
    });

    widget.videoControllers[file.key]!.addListener(() {
      final controller = widget.videoControllers[file.key]!;
      if (controller.value.position >= controller.value.duration) {
        controller.seekTo(Duration.zero);
        controller.pause();
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final multiple = widget.localFiles.length > 1;

    return Container(
      height: widget.height,
      width: double.infinity,
      alignment: Alignment.center,
      child: widget.localFiles.isEmpty
          ? _buildEmptyState(context)
          : Stack(
        fit: StackFit.expand,
        children: [
          _buildPageView(),
          if (widget.isEditing &&
              widget.localFiles.isNotEmpty &&
              widget.localFiles[currentFileIndex].type != 'audio')
            _buildDeleteButton(),
          if (multiple) _buildCounter(),
          if (widget.isEditing &&
              (widget.localFiles.isEmpty ||
                  widget.localFiles[currentFileIndex].type != 'audio'))
            _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => widget.showAddOptions(context),
        icon: const Icon(Icons.library_add, size: 20),
        label: const Text("Añadir imágenes o videos", style: TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          minimumSize: const Size(242, 37),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.localFiles.length,
      onPageChanged: (index) => setState(() => currentFileIndex = index),
      itemBuilder: (context, index) {
        final file = widget.localFiles[index];
        if (file.type == 'video' && !widget.videoControllers.containsKey(file.key)) {
          _initializeVideoController(file);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FilePreview(
              key: PageStorageKey(file.key),
              videoController: widget.videoControllers[file.key],
              type: file.type,
              url: file.url,
              onEdit: (file.type == 'audio' && widget.isEditing)
                  ? () => widget.editFile(context, 'audio', index: index)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          widget.deleteFile(currentFileIndex);
          setState(() {
            if (currentFileIndex >= widget.localFiles.length) {
              currentFileIndex =
              widget.localFiles.isEmpty ? 0 : widget.localFiles.length - 1;
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.close, color: AppColors.primary2, size: 20),
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Positioned(
      top: widget.isEditing ? 16 : null,
      bottom: widget.isEditing ? null : 16,
      left: widget.isEditing ? 16 : null,
      right: widget.isEditing ? null : 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          "${currentFileIndex + 1}/${widget.localFiles.length}",
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => widget.showAddOptions(context),
          icon: const Icon(Icons.library_add, size: 20),
          label: const Text("Añadir imágenes o videos", style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            minimumSize: const Size(242, 37),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          ),
        ),
      ),
    );
  }
}