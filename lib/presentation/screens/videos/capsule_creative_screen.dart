import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';

import 'package:flutter_frontend/providers/capsule_provider.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';

import 'package:flutter_frontend/data/models/capsule_request.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_preview_screen.dart';

class CapsuleCreativeScreen extends StatefulWidget {
  final String memorialId;
  final String memorialName;
  final String userPrompt;

  const CapsuleCreativeScreen({
    super.key,
    required this.memorialId,
    required this.memorialName,
    required this.userPrompt,
  });

  @override
  State<CapsuleCreativeScreen> createState() => _CapsuleCreativeScreenState();
}

class _CapsuleCreativeScreenState extends State<CapsuleCreativeScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedMusic;
  String _selectedFilter = 'NATURAL';

  bool _isLoading = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentPlayingTrack;

  @override
  void initState() {
    super.initState();
    // Sugerencia de título a partir del prompt
    _titleCtrl.text = widget.userPrompt;

    // Cargar catálogos
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Filtros de Cápsulas
      await context.read<CapsuleProvider>().loadFilters();
      // Música (aprovechamos el mismo catálogo de Documentales)
      await context.read<DocumentaryProvider>().loadMusicCatalog();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capsuleProvider = context.watch<CapsuleProvider>();
    final documentaryProvider = context.watch<DocumentaryProvider>();
    final filters = capsuleProvider.filters; // id, name, description

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Personaliza tu Cápsula'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Memorial + Prompt
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.memorialName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Prompt: ${widget.userPrompt}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Título (se verá al inicio del video)',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'Ej.: ${widget.userPrompt}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Descripción (opcional)',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Un breve contexto para esta cápsula…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),

            // Música
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Música',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            _MusicList(
              isLoading: documentaryProvider.loadingMusic,
              options: documentaryProvider.musicCatalog
                  .map((t) => _MusicItem(
                id: t.id,
                title: t.name,
                subtitle: '${t.description} • ${t.duration}',
              ))
                  .toList(),
              selectedId: _selectedMusic,
              onSelect: (id) => setState(() => _selectedMusic = id),
              onPreview: (id) => _toggleMusicPreview(id),
              isPlayingId: _currentPlayingTrack,
            ),
            const SizedBox(height: 24),

            // Filtro
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Filtro',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            if (capsuleProvider.loadingFilters)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'Natural',
                    value: 'NATURAL',
                    selected: _selectedFilter == 'NATURAL',
                    onTap: () => setState(() => _selectedFilter = 'NATURAL'),
                  ),
                  _FilterChip(
                    label: 'Vivid',
                    value: 'VIVID',
                    selected: _selectedFilter == 'VIVID',
                    onTap: () => setState(() => _selectedFilter = 'VIVID'),
                  ),
                  _FilterChip(
                    label: 'Dramatic',
                    value: 'DRAMATIC',
                    selected: _selectedFilter == 'DRAMATIC',
                    onTap: () => setState(() => _selectedFilter = 'DRAMATIC'),
                  ),
                  _FilterChip(
                    label: 'Yellow',
                    value: 'YELLOW',
                    selected: _selectedFilter == 'YELLOW',
                    onTap: () => setState(() => _selectedFilter = 'YELLOW'),
                  ),
                  _FilterChip(
                    label: 'Mono',
                    value: 'MONO',
                    selected: _selectedFilter == 'MONO',
                    onTap: () => setState(() => _selectedFilter = 'MONO'),
                  ),
                  _FilterChip(
                    label: 'Silvertone',
                    value: 'SILVERTONE',
                    selected: _selectedFilter == 'SILVERTONE',
                    onTap: () => setState(() => _selectedFilter = 'SILVERTONE'),
                  ),
                ],
              ),

            const SizedBox(height: 28),
            PrimaryButton(
              text: 'Generar Cápsula',
              icon: Icons.auto_awesome,
              isFullWidth: true,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _onGenerate,
            ),
            const SizedBox(height: 12),
            _HelperInfo(),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMusicPreview(String? trackId) async {
    if (trackId == null) return;

    // Si ya está sonando ese mismo track, detener
    if (_isPlaying && _currentPlayingTrack == trackId) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
      return;
    }

    // Detener cualquier reproducción previa
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // Reproducir usando tu mismo patrón (Azure blob por id)
    final base = 'https://stliriumfiles.blob.core.windows.net/lirium-files';
    final url = '$base/$trackId';

    try {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _isPlaying = true;
        _currentPlayingTrack = trackId;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo reproducir la muestra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onGenerate() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es requerido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingTrack = null;
      });
    }

    setState(() => _isLoading = true);

    final req = CapsuleRequestModel(
      memorialId: widget.memorialId,
      userPrompt: widget.userPrompt,
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      musicTrack: _selectedMusic,
      filter: _selectedFilter,
    );

    final provider = context.read<CapsuleProvider>();

    // Crear DRAFT
    final draft = await provider.createCapsule(req);

    if (!mounted) return;

    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando cápsula: ${provider.error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Iniciar generación
    final started = await provider.generateCapsule(draft.idCapsule);

    if (started != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cápsula en proceso! Te avisaremos cuando esté lista.'),
          backgroundColor: Colors.green,
        ),
      );

      // Ir a la vista previa de esa cápsula
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => CapsulePreviewScreen(capsule: started),
        ),
            (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generando cápsula: ${provider.error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }
}

class _MusicItem {
  final String id;
  final String title;
  final String subtitle;
  _MusicItem({required this.id, required this.title, required this.subtitle});
}

class _MusicList extends StatelessWidget {
  final bool isLoading;
  final List<_MusicItem> options;
  final String? selectedId;
  final void Function(String? id) onSelect;
  final Future<void> Function(String? id) onPreview;
  final String? isPlayingId;

  const _MusicList({
    required this.isLoading,
    required this.options,
    required this.selectedId,
    required this.onSelect,
    required this.onPreview,
    required this.isPlayingId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      children: [
        _musicTile(
          context,
          icon: Icons.music_off,
          label: 'Sin música',
          subtitle: 'La cápsula no tendrá fondo musical',
          selected: selectedId == null,
          trailing: null,
          onTap: () => onSelect(null),
        ),
        const SizedBox(height: 8),
        ...options.map((o) {
          final selected = selectedId == o.id;
          final playing = isPlayingId == o.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _musicTile(
              context,
              icon: Icons.music_note,
              label: o.title,
              subtitle: o.subtitle,
              selected: selected,
              trailing: IconButton(
                icon: Icon(
                  playing ? Icons.stop_circle : Icons.play_circle,
                  size: 28,
                  color: selected ? AppColors.primary : Colors.grey[600],
                ),
                onPressed: () => onPreview(o.id),
              ),
              onTap: () => onSelect(o.id),
            ),
          );
        })
      ],
    );
  }

  Widget _musicTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String subtitle,
        required bool selected,
        required VoidCallback onTap,
        Widget? trailing,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? AppColors.primary : Colors.black87,
                      )),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
            if (trailing != null) const SizedBox(width: 8),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HelperInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Formato vertical (9:16), duración máxima 1 min. Si hay menos recuerdos, ajustamos la duración.',
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
