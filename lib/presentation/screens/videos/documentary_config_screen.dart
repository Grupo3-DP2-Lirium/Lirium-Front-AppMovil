import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/documentary_request.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_area.dart';
import 'package:flutter_frontend/presentation/screens/videos/videos_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';

class DocumentaryConfigScreen extends StatefulWidget {
  final String memorialId;
  final String memorialName;
  final String title;
  final String description;

  const DocumentaryConfigScreen({
    super.key,
    required this.memorialId,
    required this.memorialName,
    required this.title,
    required this.description,
  });

  @override
  State<DocumentaryConfigScreen> createState() =>
      _DocumentaryConfigScreenState();
}

class _DocumentaryConfigScreenState extends State<DocumentaryConfigScreen> {
  final _narrativeFocusController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _selectedStyle = 'warm';
  String _selectedTone = 'nostalgic';
  String? _selectedMusic;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _currentPlayingTrack;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentaryProvider>().loadMusicCatalog();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPlayingTrack = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentaryProvider = context.watch<DocumentaryProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configuración Creativa'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Memorial info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.movie_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 1. Enfoque narrativo con CustomTextArea
            const Text(
              '1. Enfoque del relato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe cómo quieres que se enfoque este documental',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            CustomTextArea(
              label: 'Enfoque narrativo (opcional)',
              hintText: 'Ej: Que se vea su espíritu durante su niñez, con enfoque en momentos familiares importantes...',
              controller: _narrativeFocusController,
              prefixIcon: Icons.auto_stories,
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: 32),

            // 2. Estilo Visual
            const Text(
              '2. Estilo Visual del Documental',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildStyleSelector(),
            const SizedBox(height: 32),

            // 3. Tono Emocional
            const Text(
              '3. Tono Emocional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para la narración del documental',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildToneSelector(),
            const SizedBox(height: 32),

            // 4. Música
            const Text(
              '4. Música / Banda Sonora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildMusicSelector(documentaryProvider),
            const SizedBox(height: 32),

            // Botón generar
            PrimaryButton(
              text: 'Generar Documental',
              icon: Icons.auto_awesome,
              isFullWidth: true,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _generateDocumentary,
            ),
            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La generación puede tomar varios minutos. Te notificaremos cuando esté listo.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    final styles = [
      {
        'value': 'warm',
        'label': 'Cálido',
        'icon': Icons.wb_sunny,
        'description': 'Tonos cálidos y acogedores'
      },
      {
        'value': 'classic',
        'label': 'Clásico',
        'icon': Icons.photo_camera,
        'description': 'Estilo elegante y atemporal'
      },
      {
        'value': 'modern',
        'label': 'Moderno',
        'icon': Icons.auto_awesome,
        'description': 'Vibrante y contemporáneo'
      },
      {
        'value': 'natural',
        'label': 'Natural',
        'icon': Icons.nature,
        'description': 'Colores naturales y suaves'
      },
    ];

    return Column(
      children: styles.map((style) {
        final isSelected = _selectedStyle == style['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStyle = style['value'] as String;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      style['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style['label'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black87,
                          ),
                        ),
                        Text(
                          style['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToneSelector() {
    final tones = [
      {
        'value': 'nostalgic',
        'label': 'Nostálgico',
        'icon': Icons.history,
      },
      {
        'value': 'joyful',
        'label': 'Alegre',
        'icon': Icons.sentiment_satisfied_alt,
      },
      {
        'value': 'formal',
        'label': 'Formal',
        'icon': Icons.business_center,
      },
      {
        'value': 'inspiring',
        'label': 'Inspirador',
        'icon': Icons.auto_awesome,
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tones.map((tone) {
        final isSelected = _selectedTone == tone['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTone = tone['value'] as String;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tone['icon'] as IconData,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  tone['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMusicSelector(DocumentaryProvider provider) {
    if (provider.loadingMusic) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      children: [
        _buildMusicOption(null, null, 'Sin música', 'Documental sin fondo musical', null),
        const SizedBox(height: 8),

        ...provider.musicCatalog.map((track) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildMusicOption(
              track.id,
              track.previewId,
              track.name,
              '${track.description} • ${track.duration}',
              track.id,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMusicOption(
      String? trackId, String? previewId, String name, String subtitle, String? previewUrl) {
    final isSelected = _selectedMusic == previewId;
    final isPlayingThis = _isPlaying && _currentPlayingTrack == previewId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMusic = previewId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              previewId == null ? Icons.music_off : Icons.music_note,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (previewId != null) ...[
              IconButton(
                icon: Icon(
                  isPlayingThis ? Icons.stop_circle : Icons.play_circle,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  size: 32,
                ),
                onPressed: () => _toggleMusicPreview(previewId, previewUrl),
              ),
            ],
            if (isSelected && previewId != null) const SizedBox(width: 8),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMusicPreview(String trackId, String? url) async {
    if (_isPlaying && _currentPlayingTrack == trackId) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    if (trackId != null) {
      try {
        const String baseAzureUrl =
            'https://stliriumfiles.blob.core.windows.net/lirium-files';
        final String fullUrl = '$baseAzureUrl/$trackId';

        setState(() {
          _isPlaying = true;
          _currentPlayingTrack = trackId;
        });

        await _audioPlayer.play(UrlSource(fullUrl));
      } catch (e) {
        print('ERROR playing music: $e');
        setState(() {
          _isPlaying = false;
          _currentPlayingTrack = null;
        });
      }
    }
  }

  Future<void> _generateDocumentary() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
    }

    setState(() {
      _isLoading = true;
    });

    final request = DocumentaryRequestModel(
      memorialId: widget.memorialId,
      title: widget.title,
      description: widget.description.isEmpty ? null : widget.description,
      narrativeFocus: _narrativeFocusController.text.trim().isEmpty
          ? null
          : _narrativeFocusController.text.trim(),
      emotionalTone: _selectedTone,
      durationPerMemory: 5,
      musicTrack: _selectedMusic,
      styleFilter: _selectedStyle,
      transitionType: 'fade',
      resolution: '720p',
    );

    final provider = context.read<DocumentaryProvider>();

    final documentary = await provider.createDocumentary(request);

    if (!mounted) return;

    if (documentary != null) {
      final generated = await provider.generateDocumentary(documentary.idDocumentary);

      if (generated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Documental en proceso! Te notificaremos cuando esté listo.'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la lista
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VideosScreen(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error ?? "Desconocido"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _narrativeFocusController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}