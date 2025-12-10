import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../providers/capsules_by_memorial_provider.dart';

class VideosFeedTab extends StatefulWidget {
  final String memorialId;
  const VideosFeedTab({super.key, required this.memorialId});

  @override
  State<VideosFeedTab> createState() => _VideosFeedTabState();
}

class _VideosFeedTabState extends State<VideosFeedTab> {
  List<dynamic> allVideos = [];
  VideoPlayerController? videoController;
  int activeIndex = 0;
  bool allowPageSwipe = false;

  final GlobalKey _titleKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final capsulesProvider = context.read<CapsulesByMemorialProvider>();
      if (!capsulesProvider.loaded || capsulesProvider.currentMemorialId != widget.memorialId) {
        capsulesProvider.loadCapsules(memorialId: widget.memorialId, force: true);
      }
    });
  }

  void _initializeVideo(dynamic videoItem) {
    // No reinicializar el video si ya está en uso
    if (videoController != null && videoController!.dataSource == videoItem.videoUrl) {
      return; // Ya está inicializado
    }

    videoController?.dispose();
    videoController = null;
    allowPageSwipe = false;

    if (videoItem.videoUrl == null || videoItem.videoUrl!.isEmpty) return;

    videoController = VideoPlayerController.network(videoItem.videoUrl!)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        videoController!.play();
        videoController!.setLooping(true);
      });
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  void _checkTitleVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_titleKey.currentContext != null) {
        final box = _titleKey.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight && !allowPageSwipe) {
          setState(() {
            allowPageSwipe = true;
          });
        } else if (position.dy >= screenHeight && allowPageSwipe) {
          setState(() {
            allowPageSwipe = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CapsulesByMemorialProvider>(
      builder: (context, capsulesProvider, _) {
        allVideos = capsulesProvider.capsules
            .where((c) => c.videoUrl != null && c.videoUrl!.isNotEmpty)
            .toList();

        if (allVideos.isEmpty) {
          return const Center(child: Text("No hay videos"));
        }

        // Inicializamos el primer video solo una vez.
        if (videoController == null) {
          _initializeVideo(allVideos[0]);
        }

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (activeIndex == 0) {
              if (details.delta.dy > 0) {
                // Swipe hacia abajo → PageView permite swipe
                setState(() {
                  allowPageSwipe = true;
                });
              } else if (details.delta.dy < 0) {
                // Swipe hacia arriba → delega scroll al padre
                setState(() {
                  allowPageSwipe = false;
                });
              }
            }
          },
          child: Column(
            children: [
              // Usamos SizedBox para asegurar una altura específica
              SizedBox(
                height: MediaQuery.of(context).size.height, // Definir una altura basada en la pantalla
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  physics: allowPageSwipe
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: allVideos.length,
                  onPageChanged: (index) {
                    setState(() {
                      activeIndex = index;
                      _initializeVideo(allVideos[index]);
                    });
                  },
                  itemBuilder: (context, index) {
                    final videoItem = allVideos[index];
                    final isActive = index == activeIndex;

                    if (isActive && videoController != null && videoController!.value.isInitialized) {
                      _checkTitleVisibility();

                      return Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              child: VideoPlayer(videoController!),
                            ),
                          ),
                          Positioned(
                            key: _titleKey,
                            bottom: 20,
                            left: 20,
                            child: Text(
                              videoItem.title ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(color: Colors.black);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
