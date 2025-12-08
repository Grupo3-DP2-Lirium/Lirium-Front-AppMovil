import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/reflection_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import '../widget/video_player.dart';

class VideosList extends StatelessWidget {
  final List<ReflectionFile> videos;
  final Map<String, VideoPlayerController?> cachedControllers;
  final Function(ReflectionFile) onOpenVideo;

  const VideosList({
    super.key,
    required this.videos,
    required this.cachedControllers,
    required this.onOpenVideo,
  });

  void _showVideoCarousel(BuildContext context, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "VideoCarousel",
      pageBuilder: (context, anim1, anim2) {
        return PageView.builder(
          controller: PageController(initialPage: initialIndex),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return FullScreenVideoPlayer(file: videos[index]);
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  void _showAllVideosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(8),
          child: SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Todos los videos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: videos.length,
                    itemBuilder: (_, index) {
                      final video = videos[index];
                      final controller = cachedControllers[video.id];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showVideoCarousel(context, index);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (controller != null && controller.value.isInitialized)
                                AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                )
                              else
                                Container(
                                  color: Colors.black12,
                                  height: 120,
                                ),
                              const Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Videos (${videos.length})',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            )),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length > 4 ? 4 : videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: videos.length >= 4 ? 2 : videos.length,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) {
            if (index == 3 && videos.length > 4) {
              return GestureDetector(
                onTap: () => _showAllVideosDialog(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildVideoTile(context, videos[3]),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '+${videos.length - 3}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildVideoTile(context, videos[index]);
          },
        ),
      ],
    );
  }

  Widget _buildVideoTile(BuildContext context, ReflectionFile video) {
    final controller = cachedControllers[video.id];

    return GestureDetector(
      onTap: () => _showVideoCarousel(context, videos.indexOf(video)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          width: double.infinity,
          color: AppColors.inactive,
          child: controller == null
              ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
              : ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: value.size.width,
                        height: value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  if (!value.isInitialized || value.isBuffering)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 50),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
