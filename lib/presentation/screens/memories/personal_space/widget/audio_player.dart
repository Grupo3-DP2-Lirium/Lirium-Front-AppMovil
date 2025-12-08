import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String path;
  const AudioPlayerWidget({super.key, required this.path});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.path.startsWith("http")) {
      await _audioPlayer.setUrl(widget.path);
    } else {
      await _audioPlayer.setFilePath(widget.path);
    }

    // Duración total
    _audioPlayer.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });

    // Posición actual
    _audioPlayer.positionStream.listen((p) {
      setState(() => _position = p);
    });

    // Estado del player (AQUÍ SE ARREGLA EL ÍCONO)
    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      final completed = state.processingState == ProcessingState.completed;

      if (completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }

      setState(() {
        _isPlaying = playing && !completed;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            iconSize: 40,
            icon: Icon(
              _isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: AppColors.primary2,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds > 0
                      ? _duration.inSeconds.toDouble()
                      : 1,
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
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
        ],
      ),
    );
  }
}
