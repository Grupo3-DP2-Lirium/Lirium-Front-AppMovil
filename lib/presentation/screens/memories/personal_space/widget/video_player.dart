import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_frontend/data/models/reflection_model.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final ReflectionFile file;

  const FullScreenVideoPlayer({super.key, required this.file});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showPlayButton = false;

  @override
  void initState() {
    super.initState();

    // PRIORIDAD: local → si no existe, usa URL
    if (widget.file.localPath != null &&
        widget.file.localPath!.isNotEmpty &&
        File(widget.file.localPath!).existsSync()) {
      // VIDEO LOCAL
      _controller = VideoPlayerController.file(
        File(widget.file.localPath!),
      );
    } else {
      // VIDEO DESDE AZURE (NETWORK)
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.file.downloadUrl),
      );
    }

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          !_controller.value.isPlaying) {
        _controller.seekTo(Duration.zero);
        _controller.pause();
        if (mounted) setState(() {});
      }
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        _controller.seekTo(Duration.zero);
      }
      _controller.play();
    }
    setState(() {
      _showPlayButton = !_controller.value.isPlaying;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _controller.value.isPlaying;
    final isFinished = _controller.value.position >= _controller.value.duration;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // VIDEO CON GESTURE DETECTOR
          GestureDetector(
            onTap: () {
              _togglePlayPause();
            },
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),

          // BOTÓN SALIR
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // BOTÓN PLAY CENTRAL
          if (!isPlaying || isFinished || _showPlayButton)
            Center(
              child: IconButton(
                iconSize: 90,
                icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                onPressed: _togglePlayPause,
              ),
            ),

          // BARRA DE PROGRESO Y TIEMPOS ABAJO
          if (_controller.value.isInitialized)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller.value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
                        style: const TextStyle(color: Colors.white),
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
}
