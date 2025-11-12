import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_request.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_field.dart';
import 'package:flutter_frontend/presentation/components/inputs/custom_text_area.dart';
import 'package:flutter_frontend/presentation/components/inputs/filter_carousel_selector.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';

class CapsuleConfigScreen extends StatefulWidget {
  final String memorialId;
  final String memorialName;
  final String userPrompt;

  const CapsuleConfigScreen({
    super.key,
    required this.memorialId,
    required this.memorialName,
    required this.userPrompt,
  });

  @override
  State<CapsuleConfigScreen> createState() => _CapsuleConfigScreenState();
}

class _CapsuleConfigScreenState extends State<CapsuleConfigScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _selectedFilter = 'NATURAL';
  String? _selectedMusic;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _currentPlayingTrack;

  @override
  void initState() {
    super.initState();
    // Pre-llenar título basado en el prompt
    _titleController.text = _generateTitleFromPrompt(widget.userPrompt);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentaryProvider>().loadMusicCatalog();
      context.read<CapsuleProvider>().loadFilters();
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

  String _generateTitleFromPrompt(String prompt) {
    if (prompt.isEmpty) return 'Mi Cápsula';
    String title = prompt.trim();
    title = title[0].toUpperCase() + title.substring(1);
    return title.length > 50 ? '${title.substring(0, 47)}...' : title;
  }

  @override
  Widget build(BuildContext context) {
    final documentaryProvider = context.watch<DocumentaryProvider>();
    final capsuleProvider = context.watch<CapsuleProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Personaliza tu cápsula'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del prompt
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu momento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.userPrompt,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título con CustomTextField
            CustomTextField(
              label: 'Título de la cápsula',
              hintText: 'Ej: ${widget.userPrompt}',
              controller: _titleController,
              prefixIcon: const Icon(Icons.video_library_outlined, color: AppColors.primary),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Descripción con CustomTextArea
            CustomTextArea(
              label: 'Descripción (opcional)',
              hintText: 'Agrega más detalles sobre este momento...',
              controller: _descriptionController,
              prefixIcon: Icons.description,
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: 32),

            // Filtro Visual
            if (capsuleProvider.loadingFilters)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else
              FilterCarouselSelector(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filterId) {
                  setState(() {
                    _selectedFilter = filterId;
                  });
                },
                filters: capsuleProvider.filters.map((filter) {
                  return {
                    'id': filter.id,
                    'name': filter.name,
                    'description': filter.description,
                    'preview': null,
                  };
                }).toList(),
              ),
            const SizedBox(height: 32),


            // Música
            const Text(
              'Música de Fondo',
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
              text: 'Generar Cápsula',
              icon: Icons.auto_awesome,
              isFullWidth: true,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _generateCapsule,
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
                      'La generación puede tomar algunos minutos. Te notificaremos cuando esté lista.',
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

  Widget _buildFilterSelector(CapsuleProvider provider) {
    if (provider.loadingFilters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: provider.filters.map((filter) {
        final isSelected = _selectedFilter == filter.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFilter = filter.id;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  filter.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                    filter.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
        // Opción sin música
        _buildMusicOption(null, 'Sin música', 'Cápsula sin fondo musical', null),
        const SizedBox(height: 8),

        ...provider.musicCatalog.map((track) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildMusicOption(
              track.id,
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
      String? trackId, String name, String subtitle, String? previewUrl) {
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
            if (isSelected && trackId != null) const SizedBox(width: 8),
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

  Future<void> _generateCapsule() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es requerido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = CapsuleRequestModel(
      memorialId: widget.memorialId,
      userPrompt: widget.userPrompt,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      musicTrack: _selectedMusic,
      filter: _selectedFilter,
    );

    final provider = context.read<CapsuleProvider>();

    // Crear cápsula en DRAFT
    final capsule = await provider.createCapsule(request);

    if (!mounted) return;

    if (capsule != null) {
      // Iniciar generación inmediatamente
      final generated = await provider.generateCapsule(capsule.idCapsule);

      if (generated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Cápsula en proceso! Te notificaremos cuando esté lista.'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la lista
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
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
    _titleController.dispose();
    _descriptionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}