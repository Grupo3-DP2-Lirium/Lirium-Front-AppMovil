import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final String url;
  final String type; // "image" | "video"

  const FullScreenMediaViewer({
    super.key,
    required this.url,
    required this.type,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == "video") {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.url.startsWith("/") || widget.url.startsWith("file://")) {
      _controller = VideoPlayerController.file(File(widget.url));
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    }

    await _controller!.initialize();

    _controller!.addListener(() {
      final controller = _controller!;
      if (controller.value.position >= controller.value.duration &&
          !controller.value.isPlaying) {
        // Video terminó → reinicia
        controller.seekTo(Duration.zero);
        setState(() {}); // actualiza el ícono de play
      }
    });

    setState(() => _isVideoInitialized = true);
    _controller!.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: widget.type == "image"
              ? _buildImage()
              : _buildVideo(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: widget.url,
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: widget.url.startsWith("/") || widget.url.startsWith("file://")
            ? Image.file(File(widget.url))
            : Image.network(widget.url),
      ),
    );
  }

  Widget _buildVideo() {
    if (!_isVideoInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white,
              size: 80,
            ),
            onPressed: () {
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
          ),
        ],
      ),
    );
  }
}