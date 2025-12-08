import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/image_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/video_player.dart';
import 'package:video_player/video_player.dart';
import '../../../../../data/models/reflection_model.dart';
import '../../../../../data/services/reflection_service.dart';
import 'media_section.dart';
import '../new_reflection/new_reflection_screen.dart';


class ReflectionDetailScreen extends StatefulWidget {
  final ReflectionModel reflection;

  const ReflectionDetailScreen({
    super.key,
    required this.reflection,
  });

  @override
  State<ReflectionDetailScreen> createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen> {
  static final Map<String, VideoPlayerController> _cachedVideoControllers = {};

  final ReflectionService _reflectionService = ReflectionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ReflectionModel _reflection;
  bool _isPlayingAudio = false;
  String? _currentlyPlayingAudioId;
  final Map<String, VideoPlayerController> _videoControllers = {};
  bool _isLoadingVideos = true;

  @override
  void initState() {
    super.initState();
    _reflection = widget.reflection;
    //_initVideoControllers();
    _initVideoControllersOnce(); // inicializa solo si no existe en cache
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }


  void _navigateToEdit() async {
    if (!_isValidUUID(_reflection.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta reflexión debe ser guardada en el servidor primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewReflectionScreen(editingReflection: _reflection),
      ),
    );

    if (result == true && mounted) {
      final updatedReflection = await _reflectionService.getReflectionById(_reflection.id);
      if (updatedReflection != null) {
        setState(() {
          _reflection = updatedReflection;
        });

        await _refreshVideoControllers();
      }
    }

  }

  Future<void> _refreshVideoControllers() async {
    setState(() => _isLoadingVideos = true);

    final videos = _reflection.attachedFiles.where((f) => f.isVideo);

    for (final video in videos) {
      if (_cachedVideoControllers.containsKey(video.id)) continue;

      VideoPlayerController controller;
      if (video.localPath != null) {
        controller = VideoPlayerController.file(File(video.localPath!));
      } else if (video.downloadUrl.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(video.downloadUrl));
      } else {
        continue;
      }

      await controller.initialize();
      controller.setLooping(false);
      controller.pause();

      _cachedVideoControllers[video.id] = controller;
    }

    if (mounted) setState(() => _isLoadingVideos = false);
  }


  Future<void> _initVideoControllersOnce() async {
    setState(() => _isLoadingVideos = true); // mostrar loading

    final videos = _reflection.attachedFiles.where((f) => f.isVideo);

    for (final video in videos) {
      if (_cachedVideoControllers.containsKey(video.id)) continue;

      VideoPlayerController controller;
      if (video.localPath != null) {
        controller = VideoPlayerController.file(File(video.localPath!));
      } else if (video.downloadUrl.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(video.downloadUrl));
      } else {
        continue;
      }

      await controller.initialize();
      controller.setLooping(false);
      controller.pause();

      _cachedVideoControllers[video.id] = controller;
    }

    if (mounted) setState(() => _isLoadingVideos = false);
  }

  VideoPlayerController? getControllerForVideo(ReflectionFile video) {
    return _cachedVideoControllers[video.id];
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reflexión'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta reflexión? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteReflection();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio(ReflectionFile audio) async {
    try {
      if (_isPlayingAudio && _currentlyPlayingAudioId == audio.id) {
        await _audioPlayer.pause();
        setState(() {
          _isPlayingAudio = false;
          _currentlyPlayingAudioId = null;
        });
        return;
      }

      await _audioPlayer.stop();

      if (audio.localPath != null) {
        await _audioPlayer.setSource(DeviceFileSource(audio.localPath!));
      } else if (audio.downloadUrl.isNotEmpty) {
        await _audioPlayer.setSource(UrlSource(audio.downloadUrl));
      } else {
        throw "No hay fuente de audio disponible";
      }

      // Iniciar reproducción
      await _audioPlayer.resume();

      setState(() {
        _isPlayingAudio = true;
        _currentlyPlayingAudioId = audio.id;
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlayingAudio = false;
          _currentlyPlayingAudioId = null;
        });
      });
    } catch (e) {
      print("ERROR AUDIO: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir audio: $e')),
      );
    }
  }

  Future<void> _deleteReflection() async {
    try {
      await _reflectionService.deleteReflection(_reflection.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflexión eliminada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initVideoControllers() async {
    final videos = _reflection.attachedFiles.where((f) => f.isVideo);

    for (final video in videos) {
      VideoPlayerController controller;

      if (video.localPath != null) {
        controller = VideoPlayerController.file(File(video.localPath!));
      } else if (video.downloadUrl.isNotEmpty) {
        controller = VideoPlayerController.network(video.downloadUrl);
      } else {
        continue; // no hay fuente
      }

      await controller.initialize();
      controller.setLooping(false);
      controller.pause(); // deja el video en frame 0

      _videoControllers[video.id] = controller;
    }

    if (mounted) setState(() {});
  }

  void _openImage(ReflectionFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(file: file),
      ),
    );
  }

  void _openVideo(ReflectionFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(file: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _navigateToEdit();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.more_vert, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatDate(_reflection.createdDate),
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Título
            if (_reflection.title.isNotEmpty) ...[
              Text(
                _reflection.title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Contenido
            if (_reflection.content.isNotEmpty) ...[
              Text(
                _reflection.content,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Archivos multimedia
            if (_reflection.attachedFiles.isNotEmpty ) ...[
              MediaSection(
                files: _reflection.attachedFiles,
                isPlayingAudio: _isPlayingAudio,
                playingAudioId: _currentlyPlayingAudioId,
                onPlayAudio: _playAudio,
                onOpenImage: (file) => _openImage(file),
                onOpenVideo: (file) => _openVideo(file),
                cachedControllers: _cachedVideoControllers,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      '', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
    ];
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    final weekday = weekdays[date.weekday];
    final day = date.day;
    final month = months[date.month];
    final year = date.year;
    
    return '$weekday, $day de $month de $year';
  }

  bool _isValidUUID(String id) {
    if (id.isEmpty) return false;
    
    // Un UUID tiene el formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    
    return uuidRegex.hasMatch(id);
  }
}