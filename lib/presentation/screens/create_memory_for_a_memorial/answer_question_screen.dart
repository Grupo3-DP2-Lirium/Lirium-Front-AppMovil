import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/memory_saved_screen.dart';
import '../../../data/services/memory_service.dart';
import '../../../data/models/memory_create_request.dart';
import '../../../domain/enums/memory_origin_type.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

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
  
  // Audio recording variables
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _initializeRecorder();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder?.closeRecorder();
    _recordingTimer?.cancel();
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MemorySavedScreen(
              categoryName: widget.categoryName,
              question: widget.question,
              memorialId: widget.memorialId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
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
          _recordedFile = File(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al grabar video: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  void _removeVideo() {
    setState(() {
      _videoFile = null;
      _recordedFile = null;
    });
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
      _audioPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      
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
    _recordedFile?.delete();
    setState(() {
      _recordedFile = null;
      _audioPath = null;
      _recordingDuration = Duration.zero;
    });
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

  Color get _primary => const Color(0xFF6366F1);

  Widget _buildModeSelector({required String label, required IconData icon, required AnswerMode mode}) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _primary : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : Colors.black87),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                letterSpacing: .5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_mode == null) {
      return const Center(
        child: Text(
          'Selecciona un modo para responder',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_mode == AnswerMode.text) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu respuesta ...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    if (_mode == AnswerMode.video) {
      return _buildVideoContent();
    }
    
    if (_mode == AnswerMode.audio) {
      return _buildAudioContent();
    }
    
    return const Center(
      child: Text(
        'Selecciona un modo para responder',
        style: TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVideoContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_videoFile != null) ...[
            // Preview del video grabado
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video grabado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _removeVideo,
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botón para guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveMemory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : 'Guardar Video'),
              ),
            ),
          ] else ...[
            // Estado inicial - sin video
            Icon(
              Icons.videocam_outlined,
              size: 100,
              color: _primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Graba un video para responder\nesta pregunta',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isRecording ? null : _startVideoRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    : const Icon(Icons.videocam),
                label: Text(_isRecording ? 'Abriendo cámara...' : 'Grabar Video'),
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
              color: _isRecording ? Colors.red.withOpacity(0.1) : _primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              size: 60,
              color: _isRecording ? Colors.red : _primary,
            ),
          ),

          const SizedBox(height: 24),

          if (_recordedFile != null) ...[
            // Audio recorded - show controls
            Text(
              'Audio grabado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duración: ${_formatDuration(_recordingDuration)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Delete button
                OutlinedButton.icon(
                  onPressed: _deleteRecording,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                // Save button
                ElevatedButton.icon(
                  onPressed: _saving ? null : _saveMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : 'Guardar'),
                ),
              ],
            ),
          ] else if (_isRecording) ...[
            // Currently recording
            Text(
              'Grabando...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.stop),
                label: const Text('Detener Grabación'),
              ),
            ),
          ] else ...[
            // Initial state - ready to record
            const Text(
              'Toca para grabar tu mensaje de audio',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.mic),
                label: const Text('Iniciar Grabación'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Tarjeta de la pregunta
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E6EC)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildModeSelector(label: 'Grabar audio', icon: Icons.mic, mode: AnswerMode.audio),
                      _buildModeSelector(label: 'Grabar video', icon: Icons.videocam_outlined, mode: AnswerMode.video),
                      _buildModeSelector(label: 'Escribir respuesta', icon: Icons.edit_outlined, mode: AnswerMode.text),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _mode == AnswerMode.text
          ? FloatingActionButton(
              backgroundColor: (_controller.text.trim().isEmpty || _saving) ? Colors.grey : _primary,
              onPressed: (_controller.text.trim().isEmpty || _saving) ? null : _saveMemory,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }
}
