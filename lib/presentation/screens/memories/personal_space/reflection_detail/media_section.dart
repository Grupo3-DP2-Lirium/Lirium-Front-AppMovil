import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/reflection_model.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/reflection_detail/audios_list.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/reflection_detail/images_grid.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/reflection_detail/videos_list.dart';
import 'package:video_player/video_player.dart';


class MediaSection extends StatelessWidget {
  final List<ReflectionFile> files;
  final bool isPlayingAudio;
  final String? playingAudioId;
  final Function(ReflectionFile) onPlayAudio;
  final Function(ReflectionFile) onOpenImage;
  final Function(ReflectionFile) onOpenVideo;
  final Map<String, VideoPlayerController?> cachedControllers;

  const MediaSection({
    super.key,
    required this.files,
    required this.isPlayingAudio,
    required this.playingAudioId,
    required this.onPlayAudio,
    required this.onOpenImage,
    required this.onOpenVideo,
    required this.cachedControllers,
  });

  @override
  Widget build(BuildContext context) {
    final images = files.where((f) => f.isImage).toList();
    final audios = files.where((f) => f.isAudio).toList();
    final videos = files.where((f) => f.isVideo).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        const SizedBox(height: 16),
        Text("Archivos adjuntos",
            style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 16),

        if (images.isNotEmpty) ...[
          ImagesGrid(images: images, onOpenImage: onOpenImage),
          const SizedBox(height: 16),
        ],

        if (audios.isNotEmpty) ...[
          AudiosList(
            audios: audios,
            onPlayAudio: onPlayAudio,
            isPlayingAudio: isPlayingAudio,
            playingAudioId: playingAudioId,
          ),
          const SizedBox(height: 16),
        ],

        if (videos.isNotEmpty) ...[
          VideosList(
            videos: videos,
            onOpenVideo: onOpenVideo,
            cachedControllers: cachedControllers,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
