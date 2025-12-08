import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/reflection_model.dart';
import 'package:flutter_frontend/data/services/reflection_service.dart';


class AudiosList extends StatelessWidget {
  final List<ReflectionFile> audios;
  final bool isPlayingAudio;
  final String? playingAudioId;
  final Function(ReflectionFile) onPlayAudio;

  const AudiosList({
    super.key,
    required this.audios,
    required this.isPlayingAudio,
    required this.playingAudioId,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final service = ReflectionService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audios (${audios.length})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),

        ...audios.map((audio) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, color: Colors.blue.shade600),
                const SizedBox(width: 12),

                // Nombre y peso del archivo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audio.originalName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        service.formatStorageSize(audio.fileSize.toInt()),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón Play / Pause
                IconButton(
                  onPressed: () => onPlayAudio(audio),
                  icon: Icon(
                    isPlayingAudio && playingAudioId == audio.id
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          );
        })
      ],
    );
  }
}
