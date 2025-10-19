import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class FilePreview extends StatefulWidget {
  final String type; // "image" | "video" | "audio"
  final String url;
  final VoidCallback? onEdit;
  final VideoPlayerController? videoController;
  final Function(VideoPlayerController)? onVideoControllerInit;

  const FilePreview({
    super.key,
    required this.type,
    required this.url,
    this.onEdit,
    this.videoController,
    this.onVideoControllerInit,
  });

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void didUpdateWidget(covariant FilePreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo reinicializar si realmente cambió el tipo o la url
    if (widget.type != oldWidget.type || widget.url != oldWidget.url) {
      _disposeMedia();
      _initializeMedia();
    }
  }

  void _initializeMedia() {
    if (widget.url.isEmpty) return;

    switch (widget.type) {
      case "video":
      // Usamos el controlador de video proporcionado
        _videoController = widget.videoController;

        // Si el controlador no está inicializado, lo inicializamos
        if (_videoController != null && !_videoController!.value.isInitialized) {
          _initializeVideoController();
        }
        break;
      case "audio":
        _initializeAudio(widget.url);
        break;
    }
  }

  Future<void> _initializeVideoController() async {
    // Llamar al callback si es necesario
    widget.onVideoControllerInit?.call(_videoController!);

    // Escuchar el fin del video para reiniciar si es necesario
    _videoController!.addListener(() {
      if (_videoController!.value.position >= _videoController!.value.duration) {
        _videoController!.seekTo(Duration.zero);
        _videoController!.pause();
        setState(() {});
      }
    });

    setState(() {});
  }

  void _initializeAudio(String path) {
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();

    if (path.startsWith("http")) {
      _audioPlayer!.setUrl(path);
    } else {
      _audioPlayer!.setFilePath(path);
    }

    _audioPlayer!.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });
    _audioPlayer!.positionStream.listen((p) => setState(() => _position = p));
    _audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer!.seek(Duration.zero);
        _audioPlayer!.pause();
        setState(() => _position = Duration.zero);
      }
    });
  }

  void _disposeVideo() {
    if (widget.videoController == null) {
      _videoController?.dispose(); // solo si es interno
    }
    _videoController = null;
  }

  void _disposeMedia() {
    _disposeVideo();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _position = Duration.zero;
    _duration = Duration.zero;
  }

  @override
  void dispose() {
    _disposeMedia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (widget.type) {
      case "image":
        return _buildImageWidget();
      case "video":
        return _buildVideoWidget();
      case "audio":
        return _buildAudioWidget();
      default:
        return const Text("Sin vista previa");
    }
  }

  // ------------------------ IMAGEN ------------------------
  Widget _buildImageWidget() {
    if (widget.url.isEmpty) return _buildPlaceholder("Cargando video...");

    return Stack(
      children: [
        Positioned.fill(child: _buildImage(widget.url)),
        if (widget.onEdit != null) Positioned(top: 8, right: 8, child: _buildEditButton()),
      ],
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) return const Center(child: Text("Sin imagen"));

    if (url.startsWith("/") || url.startsWith("file://")) {
      return Image.file(File(url), fit: BoxFit.cover);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Text("Error al cargar imagen"));
      },
    );
  }

  // ------------------------ VIDEO ------------------------
  Widget _buildVideoWidget() {
    // Si el controlador no está inicializado, muestra cargando
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return _buildPlaceholder("Cargando video...");
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoController!),
          ValueListenableBuilder(
            valueListenable: _videoController!,
            builder: (context, VideoPlayerValue value, child) {
              return VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: AppColors.primary,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black26,
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child:
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 64,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
              ),
          ),
          if (widget.onEdit != null)
            Positioned(top: 8, right: 8, child: _buildEditButton()),
        ],
      ),
    );
  }

  // ------------------------ AUDIO ------------------------
  Widget _buildAudioWidget() {
    if (widget.url.isEmpty) return _buildPlaceholder("Sin audio");
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.inactive,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.audiotrack, size: 32, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                        onChanged: (value) {
                          _audioPlayer?.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position), style: const TextStyle(fontSize: 12)),
                          Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 40,
                  icon: Icon(
                    _audioPlayer?.playing == true ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: AppColors.primary,
                  ),
                  onPressed: () async {
                    if (_audioPlayer?.playing == true) {
                      await _audioPlayer?.pause();
                    } else {
                      await _audioPlayer?.play();
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (widget.onEdit != null) _buildEditButton(),
      ],
    );
  }

  // ------------------------ HELPERS ------------------------
  Widget _buildPlaceholder(String text) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.inactive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: text == "Cargando video..."
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 22,
        child: IconButton(
          icon: const Icon(Icons.mic, color: Colors.white),
          onPressed: widget.onEdit,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
