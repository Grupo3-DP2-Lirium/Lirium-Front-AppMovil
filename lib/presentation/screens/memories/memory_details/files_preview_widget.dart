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
  _PreviewWidgetState createState() => _PreviewWidgetState();
}

class _PreviewWidgetState extends State<PreviewWidget> {
  late int currentFileIndex;

  @override
  void initState() {
    super.initState();
    currentFileIndex = widget.currentFileIndex;
  }

  void _initializeVideoController(File file) {
    // Verificar si ya existe un controlador para este archivo y si está inicializado
    if (widget.videoControllers.containsKey(file.key) &&
        widget.videoControllers[file.key]!.value.isInitialized) {
      return; // Si ya está inicializado, no hacemos nada
    }

    // Si no existe, crear un nuevo controlador de video
    widget.videoControllers[file.key] = VideoPlayerController.networkUrl(
      Uri.parse(file.url),
    )
      ..initialize().then((_) {
        setState(() {
          // El controlador se ha inicializado correctamente
        });
      });

    // Escuchar el fin del video
    widget.videoControllers[file.key]!.addListener(() {
      if (widget.videoControllers[file.key]!.value.position >=
          widget.videoControllers[file.key]!.value.duration) {
        widget.videoControllers[file.key]!.seekTo(Duration.zero);
        widget.videoControllers[file.key]!.pause();
        setState(() {});
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
          ? Center(
        child: ElevatedButton.icon(
          onPressed: () => widget.showAddOptions(context),
          icon: const Icon(Icons.library_add, size: 20),
          label: const Text(
            "Añadir imágenes o videos",
            style: TextStyle(fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: const Size(242, 37),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Padding entre texto e icono
          ),
        ),
      )
          : Stack(
        fit: StackFit.expand,
        children: [
          // Carrusel de archivos
          PageView.builder(
            controller: PageController(initialPage: currentFileIndex),
            itemCount: widget.localFiles.length,
            onPageChanged: (index) {
              setState(() {
                currentFileIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final file = widget.localFiles[index];
              // Si el archivo es un video y no se ha creado un controlador, créalo
              if (file.type == 'video' && !widget.videoControllers.containsKey(file.key)) {
                _initializeVideoController(file);
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Contenedor principal del archivo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Expanded(
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
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Botón eliminar solo si es IMAGEN/VIDEO
          if (widget.isEditing && widget.localFiles[currentFileIndex].type != 'audio')
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  widget.deleteFile(currentFileIndex);
                  setState(() {
                    if (currentFileIndex >= widget.localFiles.length) {
                      currentFileIndex = widget.localFiles.length - 1;
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
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.primary2,
                    size: 20,
                  ),
                ),
              ),
            ),

          if (multiple)
            Positioned(
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
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  "${currentFileIndex + 1}/${widget.localFiles.length}",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),

          if (widget.isEditing && (widget.localFiles.isEmpty || widget.localFiles[currentFileIndex].type != 'audio'))
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => widget.showAddOptions(context),
                  icon: const Icon(Icons.library_add, size: 20),
                  label: const Text(
                    "Añadir imágenes o videos",
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size(242, 37),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Padding entre texto e icono
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

