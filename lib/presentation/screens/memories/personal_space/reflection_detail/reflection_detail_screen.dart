import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/image_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/personal_space/widget/video_player.dart';
import 'package:flutter_frontend/providers/reflection_provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../../data/models/reflection_model.dart';
import '../../../../../data/services/reflection_service.dart';
import '../../../../components/buttons/pop_menu_button.dart';
import '../../../../components/common/app_bar.dart';
import '../../../../components/common/app_pop_up.dart';
import 'media_section.dart';
import '../new_reflection/new_reflection_screen.dart';
import 'package:provider/provider.dart';

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
  bool _isDeleting = false;

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
    appPopupButtonDefault(
      context: context,
      title: "Eliminar reflexión",
      message:
      "¿Estás seguro de que deseas eliminar esta reflexión?\nEsta acción no se puede deshacer.",
      buttons: [
        AppPopupButton(
          text: "Cancelar",
          onPressed: () {
            Navigator.pop(context);
          },
          color: AppColors.inactive,
        ),
        AppPopupButton(
          text: "Eliminar",
          onPressed: () async {
            Navigator.pop(context);
            await _deleteReflection();
          },
          color: Colors.red,
        ),
      ],
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
      appPopupButtonDefault(
        context: context,
        title: "",
        message: "",
        buttons: [AppPopupButton(text: "", onPressed: () {})],
        isLoading: true,
      );

      final provider = Provider.of<ReflectionProvider>(context, listen: false);
      final ok = await provider.deleteReflection(_reflection.id);

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo eliminar la reflexión'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflexión eliminada con éxito'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      appBar: CustomMemoryAppBar(
        title: "Reflexión",
        onBack: () => Navigator.pop(context),
        showBackButton: true,
        appBarHeight: MediaQuery.of(context).size.height * 0.09,
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CustomPopupMenu(
            options: [
              PopupMenuOption(
                label: "Editar",
                icon: Icons.edit,
                onTap: () => _navigateToEdit(),
              ),
              PopupMenuOption(
                label: "Eliminar",
                icon: Icons.delete,
                onTap: () => _confirmDelete(),
              ),
            ],
        ),
      ),
    ),
    body:Stack(
          children: [
            SingleChildScrollView(
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
            if (_isDeleting)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
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