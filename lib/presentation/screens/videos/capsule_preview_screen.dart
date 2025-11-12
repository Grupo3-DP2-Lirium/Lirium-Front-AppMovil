import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class CapsulePreviewScreen extends StatefulWidget {
  final CapsuleModel capsule;

  const CapsulePreviewScreen({
    super.key,
    required this.capsule,
  });

  @override
  State<CapsulePreviewScreen> createState() => _CapsulePreviewScreenState();
}

class _CapsulePreviewScreenState extends State<CapsulePreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isLoadingVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.capsule.videoUrl != null &&
        (widget.capsule.isCompleted || widget.capsule.isPublished)) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoadingVideo = true;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.capsule.videoUrl!),
      );

      await _videoController!.initialize();
      await _videoController!.setLooping(true);

      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      print('ERROR initializing video: $e');
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final capsule = widget.capsule;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(capsule.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video preview (9:16 aspect ratio)
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: _buildVideoPlayer(),
                ),
              ),
            ),

            // Controles y info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Video listo
    if (_videoController != null && _videoController!.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayer(_videoController!),
          ),
          // Play/Pause button
          GestureDetector(
            onTap: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ],
      );
    }
    // Cargando video
    else if (_isLoadingVideo) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      );
    }
    // Estados sin video
    else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _buildStatusIcon(),
        ),
      );
    }
  }

  Widget _buildStatusIcon() {
    if (widget.capsule.isProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.purple),
          const SizedBox(height: 16),
          Text(
            'Generando cápsula\n${widget.capsule.progress}%',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else if (widget.capsule.isFailed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error al generar',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          if (widget.capsule.errorMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                widget.capsule.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
          ],
        ],
      );
    } else if (widget.capsule.isDraft) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_note, color: Colors.orange, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Borrador',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Icon(Icons.video_library_outlined,
          color: Colors.grey, size: 64);
    }
  }

  Widget _buildControls() {
    final capsule = widget.capsule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info básica
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capsule.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    capsule.memorialName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                capsule.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Detalles
        if (capsule.isCompleted || capsule.isPublished) ...[
          _buildDetailRow(
              Icons.photo_library, '${capsule.totalMemories} recuerdos'),
          _buildDetailRow(Icons.access_time, capsule.durationFormatted),
          _buildDetailRow(Icons.filter_vintage, 'Filtro: ${capsule.filterText}'),
          if (capsule.videoSize != null)
            _buildDetailRow(Icons.storage, capsule.sizeFormatted),
          const SizedBox(height: 16),
        ],

        // Botones de acción
        if (capsule.isCompleted) ...[
          PrimaryButton(
            text: 'Publicar en el memorial',
            icon: Icons.public,
            isFullWidth: true,
            onPressed: () => _publishCapsule(),
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            'Descargar video',
            Icons.download,
                () => _downloadVideo(),
          ),
        ],

        if (capsule.isPublished) ...[
          PrimaryButton(
            text: 'Ver en el memorial',
            icon: Icons.open_in_new,
            isFullWidth: true,
            onPressed: () {
              // TODO: Navegar al memorial
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navegar al memorial')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            'Descargar video',
            Icons.download,
                () => _downloadVideo(),
          ),
        ],

        if (capsule.isDraft) ...[
          PrimaryButton(
            text: 'Iniciar generación',
            icon: Icons.auto_awesome,
            isFullWidth: true,
            onPressed: () => _startGeneration(),
          ),
        ],

        if (capsule.isProcessing) ...[
          PrimaryButton(
            text: 'Cancelar generación',
            icon: Icons.cancel,
            isFullWidth: true,
            onPressed: () => _cancelGeneration(),
          ),
        ],

        if (capsule.isFailed) ...[
          PrimaryButton(
            text: 'Reintentar',
            icon: Icons.refresh,
            isFullWidth: true,
            onPressed: () => _startGeneration(),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.capsule.status) {
      case 'PROCESSING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'PUBLISHED':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'DRAFT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _publishCapsule() async {
    final provider = context.read<CapsuleProvider>();
    final result = await provider.publishCapsule(widget.capsule.idCapsule);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cápsula publicada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startGeneration() async {
    final provider = context.read<CapsuleProvider>();
    final result = await provider.generateCapsule(widget.capsule.idCapsule);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generación iniciada. Te notificaremos cuando esté lista.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelGeneration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar generación'),
        content: const Text('¿Estás seguro de cancelar la generación de esta cápsula?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<CapsuleProvider>();
      await provider.cancelCapsule(widget.capsule.idCapsule);
      Navigator.pop(context);
    }
  }

  Future<void> _downloadVideo() async {
    if (widget.capsule.videoUrl == null) return;

    try {
      final uri = Uri.parse(widget.capsule.videoUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el video';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}