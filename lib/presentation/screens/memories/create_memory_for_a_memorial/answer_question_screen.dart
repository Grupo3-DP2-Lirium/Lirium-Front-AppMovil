import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_create_request.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/enums/memory_origin_type.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/providers/memories_by_memorial_provider.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/// Pantalla para responder una pregunta seleccionada.
/// Soporta tres modos: grabar audio, grabar video y escribir texto (placeholder para grabaciones).
class AnswerQuestionScreen extends StatefulWidget {
  final String categoryName;
  final String question;
  final String memorialId;

  const AnswerQuestionScreen({
    super.key,
    required this.categoryName,
    required this.question,
    required this.memorialId,
  });

  @override
  State<AnswerQuestionScreen> createState() => _AnswerQuestionScreenState();
}

enum AnswerMode { audio, video, text }

class _AnswerQuestionScreenState extends State<AnswerQuestionScreen> {
  AnswerMode? _mode;
  final _controller = TextEditingController();
  final _memoryService = MemoryService();
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;
  bool _isRecording = false;
  File? _recordedFile;
  XFile? _videoFile;
  XFile? _photoFile;
  bool _isPhoto = false; // true if media is photo, false if video

  // Audio recording variables
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  bool _isPlaying = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Timer? _recordingTimer;
  Timer? _playbackTimer;

  // Video player variables
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _initializeRecorder();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    if (_mode == AnswerMode.text && _controller.text.trim().isEmpty) return;
    setState(() => _saving = true);

    try {
      final request = MemoryCreateRequest(
        memorialId: widget.memorialId,
        type: MemoryOriginType.questionResponse,
        title: widget.question,
        description: _mode == AnswerMode.text ? _controller.text.trim() : null,
        photoDate: DateTime.now(),
        associatedQuestion: widget.question,
      );

      List<File>? files;
      if (_mode == AnswerMode.audio || _mode == AnswerMode.video) {
        if (_recordedFile != null) {
          files = [_recordedFile!];
        }
      }

      await _memoryService.createMemory(request: request, files: files);

      if (mounted) {
        final createdMemoryResponse = await _memoryService.createMemory(
            request: request,
            files: files
        );

        final createdMemory = createdMemoryResponse.toEntity();

        // Actualizar MemoryProvider
        Provider.of<MemoryProvider>(context, listen: false)
            .agregarMemoria(createdMemory);

        // AGREGAR: Actualizar MemoriesByMemorialProvider
        final memoriesProvider = context.read<MemoriesByMemorialProvider>();
        memoriesProvider.addMemory(createdMemory);

        await appPopupButtonDefault(
          context: context,
          title: '¡Recuerdo guardado!',
          message: 'Tu memoria ha sido guardada exitosamente en el memorial.',
          buttons: [
            AppPopupButton(
              text: 'Aceptar',
              onPressed: () {
                // Pop 4 times to go back to MemoriesGridScreen
                // AnswerQuestionScreen -> SelectQuestionsScreen -> SelectCategoryScreen -> CreateMemoryToMemorialScreen -> MemoriesGridScreen
                int popCount = 4;
                for (int i = 0; i < popCount; i++) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se requiere permiso de cámara para grabar video'),
          ),
        );
      }
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      setState(() => _isRecording = true);

      await _requestCameraPermission();

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
        preferredCameraDevice: CameraDevice.rear,
      );

      if (video != null) {
        setState(() {
          _videoFile = video;
          _photoFile = null;
          _recordedFile = File(video.path);
          _isPhoto = false;
        });
        await _initializeVideoPlayer(video.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al grabar video: $e')));
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  void _removeVideo() {
    _videoController?.dispose();
    setState(() {
      _videoFile = null;
      _photoFile = null;
      _recordedFile = null;
      _videoController = null;
      _isVideoInitialized = false;
      _isVideoPlaying = false;
      _isPhoto = false;
    });
  }

  // Show media options modal
  void _showMediaOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.image_outlined, color: _primary),
                ),
                title: const Text(
                  'Añadir imagen',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '1:1',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _showImageSourceModal();
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.videocam_outlined, color: _primary),
                ),
                title: const Text(
                  'Añadir video',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(Icons.rectangle_outlined, size: 20, color: Colors.grey[400]),
                onTap: () {
                  Navigator.pop(modalContext);
                  _showVideoSourceModal();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Show image source selection (camera or gallery)
  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: _primary),
                ),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: _primary),
                ),
                title: const Text(
                  'Elegir de galería',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Show video source selection (camera or gallery)
  void _showVideoSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.videocam_outlined, color: _primary),
                ),
                title: const Text(
                  'Grabar video',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  await _startVideoRecording();
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.video_library_outlined, color: _primary),
                ),
                title: const Text(
                  'Elegir de galería',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  await _pickVideoFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isRecording = true);

      if (source == ImageSource.camera) {
        await _requestCameraPermission();
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photoFile = image;
          _videoFile = null;
          _recordedFile = File(image.path);
          _isPhoto = true;
          _isVideoInitialized = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  // Pick video from gallery
  Future<void> _pickVideoFromGallery() async {
    try {
      setState(() => _isRecording = true);

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _videoFile = video;
          _photoFile = null;
          _recordedFile = File(video.path);
          _isPhoto = false;
        });
        await _initializeVideoPlayer(video.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar video: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  // Video player methods
  Future<void> _initializeVideoPlayer(String path) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(path));
      await _videoController!.initialize();
      _videoController!.addListener(_videoListener);
      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _videoListener() {
    if (_videoController == null) return;

    final isPlaying = _videoController!.value.isPlaying;
    if (_isVideoPlaying != isPlaying) {
      if (mounted) setState(() => _isVideoPlaying = isPlaying);
    }

    // Check if video ended
    if (_videoController!.value.position >= _videoController!.value.duration) {
      if (mounted) {
        setState(() => _isVideoPlaying = false);
      }
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController == null || !_isVideoInitialized) return;

    if (_isVideoPlaying) {
      _videoController!.pause();
    } else {
      // If at end, restart from beginning
      if (_videoController!.value.position >=
          _videoController!.value.duration) {
        _videoController!.seekTo(Duration.zero);
      }
      _videoController!.play();
    }
  }

  String _formatVideoDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openFullscreenVideo() {
    if (_videoController == null || !_isVideoInitialized) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPlayer(
          videoController: _videoController!,
          primaryColor: _primary,
        ),
      ),
    );
  }

  // Audio recording methods
  Future<void> _initializeRecorder() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();
      _isRecorderInitialized = true;
    } catch (e) {
      _isRecorderInitialized = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize audio recorder')),
        );
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _audioPlayer = FlutterSoundPlayer();
      await _audioPlayer!.openPlayer();
      _isPlayerInitialized = true;
    } catch (e) {
      _isPlayerInitialized = false;
      debugPrint('Failed to initialize audio player: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    return await Permission.microphone.isGranted ||
        await Permission.microphone.request().isGranted;
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recorder not initialized')),
        );
      }
      return;
    }

    if (!await _checkPermissions()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      _audioPath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(
        toFile: _audioPath!,
        codec: Codec.aacADTS,
      );

      setState(() => _isRecording = true);
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start recording')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _audioRecorder == null) return;

    try {
      await _audioRecorder!.stopRecorder();
      _stopTimer();

      if (_audioPath != null && mounted) {
        setState(() {
          _isRecording = false;
          _recordedFile = File(_audioPath!);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to stop recording')),
        );
      }
    }
  }

  void _deleteRecording() {
    _stopPlayback();
    _recordedFile?.delete();
    setState(() {
      _recordedFile = null;
      _audioPath = null;
      _recordingDuration = Duration.zero;
      _playbackPosition = Duration.zero;
    });
  }

  // Audio playback methods
  Future<void> _startPlayback() async {
    if (!_isPlayerInitialized || _audioPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede reproducir el audio')),
        );
      }
      return;
    }

    try {
      await _audioPlayer!.startPlayer(
        fromURI: _audioPath!,
        codec: Codec.aacADTS,
        whenFinished: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _playbackPosition = Duration.zero;
            });
            _stopPlaybackTimer();
          }
        },
      );

      setState(() => _isPlaying = true);
      _startPlaybackTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al reproducir: $e')));
      }
    }
  }

  Future<void> _stopPlayback() async {
    if (!_isPlaying || _audioPlayer == null) return;

    try {
      await _audioPlayer!.stopPlayer();
      _stopPlaybackTimer();
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
      });
    } catch (e) {
      debugPrint('Error stopping playback: $e');
    }
  }

  Future<void> _pausePlayback() async {
    if (!_isPlaying || _audioPlayer == null) return;

    try {
      await _audioPlayer!.pausePlayer();
      _stopPlaybackTimer();
      setState(() => _isPlaying = false);
    } catch (e) {
      debugPrint('Error pausing playback: $e');
    }
  }

  Future<void> _resumePlayback() async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.resumePlayer();
      setState(() => _isPlaying = true);
      _startPlaybackTimer();
    } catch (e) {
      debugPrint('Error resuming playback: $e');
    }
  }

  void _startPlaybackTimer() {
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          _playbackPosition = Duration(
            milliseconds: _playbackPosition.inMilliseconds + 100,
          );
          // No permitir que exceda la duración total
          if (_playbackPosition > _recordingDuration) {
            _playbackPosition = _recordingDuration;
          }
        });
      }
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _startTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color get _primary => AppColors.primary;

  Widget _buildModeSelector({
    required String label,
    required IconData icon,
    required AnswerMode mode,
    String? subtitle,
  }) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _primary : AppColors.inactive,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: selected ? Colors.white : _primary,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: selected
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : AppColors.inactive,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 16, color: _primary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_mode == AnswerMode.text) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 5,
          style: AppColors.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta ...',
            hintStyle: AppColors.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.inactive.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      );
    }

    if (_mode == AnswerMode.video) {
      return _buildVideoContent();
    }

    if (_mode == AnswerMode.audio) {
      return _buildAudioContent();
    }

    return const SizedBox.shrink();
  }

  Widget _buildVideoContent() {
    final bool hasMedia = _videoFile != null || _photoFile != null;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasMedia) ...[
            // Media preview
            if (_isPhoto && _photoFile != null) ...[
              // Photo preview
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(_photoFile!.path),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Imagen seleccionada',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ] else if (!_isPhoto && _videoFile != null) ...[
              // Video thumbnail preview
              GestureDetector(
                onTap: _openFullscreenVideo,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isVideoInitialized && _videoController != null)
                        Positioned.fill(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController!.value.size.width,
                              height: _videoController!.value.size.height,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        ),
                      Container(color: Colors.black.withOpacity(0.3)),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      if (_isVideoInitialized && _videoController != null)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatVideoDuration(
                                _videoController!.value.duration,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (!_isVideoInitialized)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: _primary),
                            const SizedBox(height: 12),
                            const Text(
                              'Cargando video...',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Toca para ver el video',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removeVideo,
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    label: Text(
                      'Eliminar',
                      style: TextStyle(
                        color: AppColors.error,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(
                      _saving ? 'Guardando...' : 'Guardar',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Estado inicial - sin media
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.photo_camera_outlined, size: 48, color: _primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Añade fotos o videos para\nresponder esta pregunta',
              style: AppColors.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isRecording ? null : _showMediaOptionsModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isRecording
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _isRecording ? 'Cargando...' : 'Añadir multimedia',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main icon with animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _isRecording
                  ? AppColors.error.withOpacity(0.1)
                  : _primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              size: 56,
              color: _isRecording ? AppColors.error : _primary,
            ),
          ),

          const SizedBox(height: 24),

          if (_recordedFile != null) ...[
            // Audio recorded - show player and controls
            Text(
              'Audio grabado',
              style: AppColors.h5.copyWith(color: _primary),
            ),
            const SizedBox(height: 16),

            // Audio player card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _recordingDuration.inMilliseconds > 0
                          ? _playbackPosition.inMilliseconds /
                                _recordingDuration.inMilliseconds
                          : 0,
                      backgroundColor: _primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_playbackPosition),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Play/Pause button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Restart button
                      IconButton(
                        onPressed: () {
                          _stopPlayback();
                          setState(() => _playbackPosition = Duration.zero);
                        },
                        icon: Icon(Icons.replay, color: _primary, size: 28),
                      ),
                      const SizedBox(width: 16),

                      // Play/Pause main button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_isPlaying) {
                              _pausePlayback();
                            } else if (_playbackPosition > Duration.zero &&
                                _playbackPosition < _recordingDuration) {
                              _resumePlayback();
                            } else {
                              _startPlayback();
                            }
                          },
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Stop button
                      IconButton(
                        onPressed: _isPlaying ? _stopPlayback : null,
                        icon: Icon(
                          Icons.stop,
                          color: _isPlaying
                              ? _primary
                              : AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Delete button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteRecording,
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    label: Text(
                      'Eliminar',
                      style: TextStyle(
                        color: AppColors.error,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(
                      _saving ? 'Guardando...' : 'Guardar',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_isRecording) ...[
            // Currently recording
            Text(
              'Grabando...',
              style: AppColors.h5.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_recordingDuration),
              style: AppColors.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.stop),
                label: const Text(
                  'Detener Grabación',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Initial state - ready to record
            Text(
              'Toca para grabar tu mensaje de audio',
              style: AppColors.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.mic),
                label: const Text(
                  'Iniciar Grabación',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: widget.categoryName,
        onBack: () => Navigator.pop(context),
        showBackButton: true,
        appBarHeight: MediaQuery.of(context).size.height * 0.09,
      ),
      body: Column(
        children: [
          // Tarjeta de la pregunta y selectores
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pregunta
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _primary.withOpacity(0.08),
                          _primary.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.question,
                            style: AppColors.h5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Título de la sección
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '¿Cómo deseas responder?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Opciones de modo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildModeSelector(
                          label: 'Grabar audio',
                          subtitle: 'Graba tu voz respondiendo la pregunta',
                          icon: Icons.mic,
                          mode: AnswerMode.audio,
                        ),
                        const SizedBox(height: 12),
                        _buildModeSelector(
                          label: 'Grabar video',
                          subtitle: 'Captura un video con tu respuesta',
                          icon: Icons.videocam_outlined,
                          mode: AnswerMode.video,
                        ),
                        const SizedBox(height: 12),
                        _buildModeSelector(
                          label: 'Escribir respuesta',
                          subtitle: 'Escribe tu respuesta en texto',
                          icon: Icons.edit_outlined,
                          mode: AnswerMode.text,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contenido del modo seleccionado
                  if (_mode != null) ...[
                    Divider(height: 1, color: AppColors.inactive),
                    _buildBody(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _mode == AnswerMode.text
          ? FloatingActionButton(
              backgroundColor: (_controller.text.trim().isEmpty || _saving)
                  ? AppColors.textSecondary
                  : _primary,
              elevation: 4,
              onPressed: (_controller.text.trim().isEmpty || _saving)
                  ? null
                  : _saveMemory,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }
}

/// Fullscreen video player widget
class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final Color primaryColor;

  const _FullscreenVideoPlayer({
    required this.videoController,
    required this.primaryColor,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    widget.videoController.addListener(_videoListener);
    _isPlaying = widget.videoController.value.isPlaying;
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_videoListener);
    _hideControlsTimer?.cancel();
    // Pause when leaving fullscreen
    widget.videoController.pause();
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      final isPlaying = widget.videoController.value.isPlaying;
      if (_isPlaying != isPlaying) {
        setState(() => _isPlaying = isPlaying);
      }

      // Check if video ended
      if (widget.videoController.value.position >=
          widget.videoController.value.duration) {
        setState(() {
          _isPlaying = false;
          _showControls = true;
        });
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      widget.videoController.pause();
    } else {
      if (widget.videoController.value.position >=
          widget.videoController.value.duration) {
        widget.videoController.seekTo(Duration.zero);
      }
      widget.videoController.play();
      _startHideControlsTimer();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: widget.videoController.value.aspectRatio,
                child: VideoPlayer(widget.videoController),
              ),
            ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top bar with close button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Vista previa',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),

                      // Center play/pause button
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: _togglePlayback,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: widget.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom progress bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: widget.videoController,
                          builder: (context, value, child) {
                            final position = value.position;
                            final duration = value.duration;
                            final progress = duration.inMilliseconds > 0
                                ? position.inMilliseconds /
                                      duration.inMilliseconds
                                : 0.0;

                            return Column(
                              children: [
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.primaryColor,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Time labels
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
