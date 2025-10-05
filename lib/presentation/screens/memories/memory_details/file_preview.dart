import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class FilePreview extends StatefulWidget {
  final String type; // "image" | "video" | "audio"
  final String url;
  final VoidCallback? onEdit;

  const FilePreview({
    super.key,
    required this.type,
    required this.url,
    this.onEdit,
  });

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
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

    // Actualizar video si cambia la url
    if (widget.type == "video" && widget.url != oldWidget.url) {
      _videoController?.dispose();
      if (widget.url.isNotEmpty) {
        _videoController = VideoPlayerController.file(File(widget.url))
          ..initialize().then((_) => setState(() {}));
      }
    }

    // Actualizar audio si cambia la url
    if (widget.type == "audio" && widget.url != oldWidget.url) {
      _audioPlayer?.dispose();
      if (widget.url.isNotEmpty) {
        _audioPlayer = AudioPlayer();
        _audioPlayer!.setUrl(widget.url);
        _audioPlayer!.durationStream.listen((d) {
          if (d != null) setState(() => _duration = d);
        });
        _audioPlayer!.positionStream.listen((p) {
          setState(() => _position = p);
        });
        _audioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _position = Duration.zero);
            _audioPlayer!.seek(Duration.zero);
            _audioPlayer!.pause();
          }
        });
      }
    }
  }

  void _initializeMedia() {
    if (widget.type == "video" && widget.url.isNotEmpty) {
      _videoController = VideoPlayerController.file(File(widget.url))
        ..initialize().then((_) => setState(() {}));
    }

    if (widget.type == "audio" && widget.url.isNotEmpty) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.setUrl(widget.url);
      _audioPlayer!.durationStream.listen((d) {
        if (d != null) setState(() => _duration = d);
      });
      _audioPlayer!.positionStream.listen((p) {
        setState(() => _position = p);
      });
      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => _position = Duration.zero);
          _audioPlayer!.seek(Duration.zero);
          _audioPlayer!.pause();
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == "image") return _buildImageWidget();
    if (widget.type == "video") return _buildVideoWidget();
    if (widget.type == "audio") return _buildAudioWidget();
    return const Text("Sin vista previa");
  }

  // ------------------------ IMAGEN ------------------------
  Widget _buildImageWidget() {
    if (widget.url.isEmpty) return _buildPlaceholder("Sin vista previa de imagen");

    return Stack(
      children: [
        Positioned.fill(child: _buildImage(widget.url)),
        if (widget.onEdit != null) Positioned(top: 8, right: 8, child: _buildEditButton()),
      ],
    );
  }

  Widget _buildImage(String data) {
    if (data.startsWith("http")) return Image.network(data, fit: BoxFit.cover);
    if (data.startsWith("/")) return Image.file(File(data), fit: BoxFit.cover);
    try {
      return Image.memory(base64Decode(data), fit: BoxFit.cover);
    } catch (e) {
      return const Center(child: Text("Error al cargar imagen"));
    }
  }

  // ------------------------ VIDEO ------------------------
  Widget _buildVideoWidget() {
    if (widget.url.isEmpty) return _buildPlaceholder("Sin vista previa de video", showEdit: true);
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoController!),
          VideoProgressIndicator(_videoController!, allowScrubbing: true),
          Align(
            alignment: Alignment.center,
            child: IconButton(
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
          if (widget.onEdit != null) Positioned(top: 8, right: 8, child: _buildEditButton()),
        ],
      ),
    );
  }

  // ------------------------ AUDIO ------------------------
  Widget _buildAudioWidget() {
    if (widget.url.isEmpty) return _buildPlaceholder("Sin audio", showEdit: true, icon: Icons.mic);

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
  Widget _buildPlaceholder(String text, {bool showEdit = false, IconData? icon}) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.inactive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 32, color: Colors.black54),
            if (icon != null) const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            if (showEdit && widget.onEdit != null) ...[
              const SizedBox(width: 12),
              _buildEditButton(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 22,
        child: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
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