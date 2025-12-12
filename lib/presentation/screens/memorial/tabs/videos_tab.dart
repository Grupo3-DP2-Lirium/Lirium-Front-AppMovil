import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../../../providers/capsules_by_memorial_provider.dart';
import '../../../../providers/documentary_by_memorial_provider.dart';
import '../../../components/common/app_colors.dart';

class VideosTab extends StatefulWidget {
  final String memorialId;
  final ScrollController parentScrollController;

  const VideosTab({
    super.key,
    required this.memorialId,
    required this.parentScrollController,
  });

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  VideoPlayerController? videoController;
  bool _firstVideoFullyVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final capsulesProvider = context.read<CapsulesByMemorialProvider>();
      final docsProvider = context.read<DocumentariesByMemorialProvider>();

      if (!capsulesProvider.loaded || capsulesProvider.currentMemorialId != widget.memorialId) {
        capsulesProvider.loadCapsules(memorialId: widget.memorialId, force: true);
      }
      if (!docsProvider.loaded || docsProvider.currentMemorialId != widget.memorialId) {
        // docsProvider.loadDocumentaries(memorialId: widget.memorialId, force: true);
      }
    });
  }

  void _initializeVideo(dynamic videoItem) {
    if (videoController != null) {
      videoController!.pause();
      videoController!.dispose();
    }

    if (videoItem.videoUrl == null || videoItem.videoUrl!.isEmpty) return;

    videoController = VideoPlayerController.network(videoItem.videoUrl!)
      ..initialize().then((_) {
        setState(() {});
        videoController!.play();
        videoController!.setLooping(true);
      });
  }

  @override
  void dispose() {
    videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    final parent = widget.parentScrollController;
    if (!parent.hasClients) return false;

    if (_currentPage == 0 && n is ScrollUpdateNotification) {
      final dy = n.scrollDelta ?? 0;

      // Solo el primer scroll hacia abajo
      if (!_firstVideoFullyVisible && dy > 0) {
        // Marcar que el primer video ya fue visto completamente
        _firstVideoFullyVisible = true;
        return true; // bloquear PageView hasta que video0 se vea
      }

      // Ceder scroll al padre si ya se vio video0
      if (_firstVideoFullyVisible) {
        if (dy > 0 && parent.offset < parent.position.maxScrollExtent) {
          parent.jumpTo((parent.offset + dy).clamp(0.0, parent.position.maxScrollExtent));
          return true;
        }
        if (dy < 0 && parent.offset > 0) {
          parent.jumpTo((parent.offset + dy).clamp(0.0, parent.position.maxScrollExtent));
          return true;
        }
      }
    }

    return false; // resto de páginas scroll normal
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CapsulesByMemorialProvider, DocumentariesByMemorialProvider>(
      builder: (context, capsulesProvider, docsProvider, _) {
        final allVideos = [
          ...capsulesProvider.capsules.where((c) => c.videoUrl != null && c.videoUrl!.isNotEmpty && c.publishedDate != null),
          // ...docsProvider.documentaries.where((d) => d.videoUrl != null && d.videoUrl!.isNotEmpty)
        ];

        if (!capsulesProvider.loaded) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (allVideos.isEmpty) {
          return const Center(
            child: Text(
              "No hay videos",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                _currentPage = index;
                _initializeVideo(allVideos[index]);
              },
              itemCount: allVideos.length,
              itemBuilder: (context, index) {
                final videoItem = allVideos[index];
                final isActive = index == _currentPage;
                return _buildVideoPage(videoItem, isActive);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPage(dynamic videoItem, bool isActive) {
    if (isActive && videoController == null) {
      _initializeVideo(videoItem);
    }

    final String formattedDate = videoItem.publishedDate != null
        ? "${videoItem.publishedDate.day.toString().padLeft(2, '0')} "
        "${_monthName(videoItem.publishedDate.month)} "
        "${videoItem.publishedDate.year}"
        : "";

    return Stack(
      children: [
        // Video fondo
        if (isActive && videoController != null && videoController!.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController!.value.size.width,
                height: videoController!.value.size.height,
                child: VideoPlayer(videoController!),
              ),
            ),
          )
        else
          Container(color: Colors.black),

        // Título + Fecha arriba
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  videoItem.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    shadows: const [
                      Shadow(offset: Offset(0, 1.5), blurRadius: 4, color: Colors.black87),
                    ],
                  ),
                ),
              ),

              if (formattedDate.isNotEmpty)
                Text(
                  formattedDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    shadows: const [
                      Shadow(offset: Offset(0, 1.5), blurRadius: 4, color: Colors.black87),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Descripción abajo
        if ((videoItem.description ?? "").isNotEmpty)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              videoItem.description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w400,
                shadows: const [
                  Shadow(offset: Offset(0, 1.2), blurRadius: 3, color: Colors.black87),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      "Ene", "Feb", "Mar", "Abr", "May", "Jun",
      "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"
    ];
    return months[month - 1];
  }

}
