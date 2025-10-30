import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/documentary_request.dart';
import 'package:flutter_frontend/data/models/music_track_model.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class CreateDocumentaryScreen extends StatefulWidget {
  const CreateDocumentaryScreen({super.key});

  @override
  State<CreateDocumentaryScreen> createState() => _CreateDocumentaryScreenState();
}

class _CreateDocumentaryScreenState extends State<CreateDocumentaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _selectedMemorialId;
  int _durationPerMemory = 5;
  String? _selectedMusic;
  String _selectedStyle = 'warm';
  String _selectedResolution = '720p';
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _currentPlayingTrack;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar memoriales si no están cargados
      final memorialProvider = context.read<MemorialProvider>();
      if (!memorialProvider.loadedMis) {
        memorialProvider.cargarMisMemoriales();
      }

      // Cargar catálogo de música
      context.read<DocumentaryProvider>().loadMusicCatalog();
    });

    // Escuchar cambios de estado del reproductor
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final memorialProvider = context.watch<MemorialProvider>();
    final documentaryProvider = context.watch<DocumentaryProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Documental'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: memorialProvider.cargandoMis
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleccionar Memorial
              const Text(
                'Memorial',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildMemorialSelector(memorialProvider),
              const SizedBox(height: 24),

              // Título
              const Text(
                'Título del documental',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej: La vida de Jorge',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Descripción
              const Text(
                'Descripción (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe brevemente este documental...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),

              // Duración por recuerdo
              const Text(
                'Duración por recuerdo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildDurationSelector(),
              const SizedBox(height: 24),

              // Música de fondo
              const Text(
                'Música de fondo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildMusicSelector(documentaryProvider),
              const SizedBox(height: 24),

              // Estilo visual
              const Text(
                'Estilo visual',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildStyleSelector(),
              const SizedBox(height: 24),

              // Resolución
              const Text(
                'Resolución',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildResolutionSelector(),
              const SizedBox(height: 32),

              // Botón Generar
              PrimaryButton(
                text: 'Generar Documental',
                icon: Icons.movie_creation_outlined,
                isFullWidth: true,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _createDocumentary,
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
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La generación puede tomar varios minutos. Te notificaremos cuando esté listo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorialSelector(MemorialProvider provider) {
    if (provider.misMemoriales.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No tienes memoriales aún. Crea uno primero.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedMemorialId,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
      ),
      hint: const Text('Selecciona un memorial'),
      items: provider.misMemoriales.map((memorial) {
        return DropdownMenuItem(
          value: memorial.idMemorial,
          child: Text(memorial.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMemorialId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona un memorial';
        }
        return null;
      },
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      children: [
        _buildDurationChip(3),
        const SizedBox(width: 8),
        _buildDurationChip(5),
        const SizedBox(width: 8),
        _buildDurationChip(8),
      ],
    );
  }

  Widget _buildDurationChip(int seconds) {
    final isSelected = _durationPerMemory == seconds;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _durationPerMemory = seconds;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
            ),
          ),
          child: Text(
            '$seconds seg',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
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

    if (provider.musicCatalog.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Sin música (se generará sin fondo musical)',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Opción "Sin música"
        _buildMusicOption(null, 'Sin música', 'Documental sin fondo musical', null),
        const SizedBox(height: 8),

        // Lista de música
        ...provider.musicCatalog.map((track) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildMusicOption(
              track.id,
              track.name,
              '${track.description} • ${track.duration}',
              track.id, // URL del track para reproducir
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMusicOption(String? trackId, String name, String subtitle, String? previewUrl) {
    final isSelected = _selectedMusic == trackId;
    final isPlayingThis = _isPlaying && _currentPlayingTrack == trackId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMusic = trackId;
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
              trackId == null ? Icons.music_off : Icons.music_note,
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
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Botón de preview (solo si no es "Sin música")
            if (trackId != null) ...[
              IconButton(
                icon: Icon(
                  isPlayingThis ? Icons.stop_circle : Icons.play_circle,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  size: 32,
                ),
                onPressed: () => _toggleMusicPreview(trackId, previewUrl),
              ),
            ],
            if (isSelected && trackId != null)
              const SizedBox(width: 8),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMusicPreview(String trackId, String? url) async {
    // Si está reproduciendo esta canción, detener
    if (_isPlaying && _currentPlayingTrack == trackId) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
      return;
    }

    // Si está reproduciendo otra canción, detener primero
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // Reproducir la nueva canción
    if (url != null) {
      try {
        // Aquí deberías usar la URL completa del archivo de música en Azure
        // Por ahora, como ejemplo usamos una URL de prueba
        // await _audioPlayer.play(UrlSource(url));

        // TEMPORAL: Mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reproduciendo: $trackId'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        setState(() {
          _isPlaying = true;
          _currentPlayingTrack = trackId;
        });

        // Simular reproducción de 3 segundos
        await Future.delayed(const Duration(seconds: 3));

        if (_currentPlayingTrack == trackId) {
          setState(() {
            _isPlaying = false;
            _currentPlayingTrack = null;
          });
        }
      } catch (e) {
        print('ERROR playing music: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al reproducir música'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStyleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStyleChip('warm', 'Cálido', Icons.wb_sunny),
        _buildStyleChip('sepia', 'Sepia', Icons.filter_vintage),
        _buildStyleChip('bw', 'Blanco y Negro', Icons.filter_b_and_w),
        _buildStyleChip('vibrant', 'Vibrante', Icons.color_lens),
      ],
    );
  }

  Widget _buildStyleChip(String value, String label, IconData icon) {
    final isSelected = _selectedStyle == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStyle = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionSelector() {
    return Row(
      children: [
        _buildResolutionChip('480p'),
        const SizedBox(width: 8),
        _buildResolutionChip('720p'),
        const SizedBox(width: 8),
        _buildResolutionChip('1080p'),
      ],
    );
  }

  Widget _buildResolutionChip(String resolution) {
    final isSelected = _selectedResolution == resolution;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedResolution = resolution;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
            ),
          ),
          child: Text(
            resolution,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createDocumentary() async {
    if (!_formKey.currentState!.validate()) return;

    // Detener música si está sonando
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
      memorialId: _selectedMemorialId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      durationPerMemory: _durationPerMemory,
      musicTrack: _selectedMusic,
      styleFilter: _selectedStyle,
      transitionType: 'fade',
      resolution: _selectedResolution,
    );

    final provider = context.read<DocumentaryProvider>();
    final documentary = await provider.createDocumentary(request);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (documentary != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documental creado. La generación ha comenzado...'),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}