import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/models/user_lite_response.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/banner_ia.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_filter_chips.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/format_type_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/moment_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/theme_detail_screen.dart';
import 'package:flutter_frontend/providers/memories_by_memorial_provider.dart';
import 'package:provider/provider.dart';

class MemoriesTab extends StatefulWidget {
  final String memorialId;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const MemoriesTab({
    super.key,
    required this.memorialId,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'all';

  // Filtros disponibles
  final List<FilterChipData> _filters = const [
    FilterChipData(key: 'all', label: 'Recientes', icon: Icons.access_time_rounded),
    FilterChipData(key: 'gallery', label: 'Galería', icon: Icons.photo_library_rounded),
    FilterChipData(key: 'images', label: 'Formato', icon: Icons.image_rounded),
    FilterChipData(key: 'timeline', label: 'Línea de Tiempo', icon: Icons.timeline_rounded),
    FilterChipData(key: 'themes', label: 'Temáticas', icon: Icons.category_rounded),
    FilterChipData(key: 'moments', label: 'Momentos', icon: Icons.ac_unit_rounded),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // FIX: Cargar memorias con validación de memorial correcto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MemoriesByMemorialProvider>();

      // Solo cargar si:
      // 1. No está cargado aún, O
      // 2. Es un memorial diferente
      final needsLoad = !provider.loaded ||
          provider.currentMemorialId != widget.memorialId;

      if (needsLoad) {
        print('📡 Cargando memorias para memorial: ${widget.memorialId}');
        provider.loadMemories(memorialId: widget.memorialId, force: true);
      } else {
        print('✅ Memorias ya cargadas para este memorial');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Chips de filtro
        MemorialFilterChips(
          selectedFilter: _selectedFilter,
          onFilterChanged: (key) => setState(() => _selectedFilter = key),
          filters: _filters,
        ),

        // Contenido según filtro
        _buildFilteredContent(),
      ],
    );
  }

  Widget _buildFilteredContent() {
    switch (_selectedFilter) {
      case 'all':
        return _buildActivityContent();
      case 'gallery':
        return _buildGalleryGridContent();
      case 'images':
        return _buildFormatTypeContent();
      case 'timeline':
        return _buildTimelineContent();
      case 'themes':
        return _buildThemesContent();
      case 'moments': //pendiente
        return _buildMomentsContent();
      default:
        return _buildActivityContent();
    }
  }

  // ============ RECIENTES (FEED STYLE) ============
  Widget _buildActivityContent() {
    return Consumer<MemoriesByMemorialProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.memories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (provider.memories.isEmpty) {
          return _buildEmptyState('No hay recuerdos', Icons.photo_library_outlined);
        }

        final memories = provider.memories.map((m) => _memoryToResponse(m)).toList();

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: memories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildMemoryFeedCard(memories[index]),
        );
      },
    );
  }

  Widget _buildMemoryFeedCard(MemoryResponse memory) {
    final hasImages = memory.files.any((f) => f.isImage);
    final hasVideos = memory.files.any((f) => f.isVideo);
    final hasAudio = memory.files.any((f) => f.fileType == 'audio');
    final isTextOnly = memory.files.isEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToMemoryDetail(memory),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Autor + Fecha
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: memory.author?.profilePhotoUrl != null
                        ? NetworkImage(memory.author!.profilePhotoUrl!)
                        : null,
                    child: memory.author?.profilePhotoUrl == null
                        ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.author?.name ?? 'Usuario',
                          style: AppColors.labelLarge.copyWith(fontSize: 15),
                        ),
                        Text(
                          _formatTimeAgo(memory.createdDate),
                          style: AppColors.labelSmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Badge de tipo
                  _buildTypeBadgeForMemory(memory),
                ],
              ),
            ),

            // Título y descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (memory.title.isNotEmpty) ...[
                    Text(
                      memory.title,
                      style: AppColors.h6.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (memory.description.isNotEmpty)
                    Text(
                      memory.description,
                      style: AppColors.bodyMedium,
                      maxLines: isTextOnly ? 10 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Media content
            if (hasImages || hasVideos) ...[
              const SizedBox(height: 12),
              _buildMediaGrid(memory.files),
            ],

            // Audio player
            if (hasAudio) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildAudioPlayer(memory.files.firstWhere((f) => f.fileType == 'audio')),
              ),
            ],

            // Footer: Tags, categorías
            /*if (memory.categorias.isNotEmpty || memory.momentos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...memory.categorias.map((cat) => _buildTag(cat, Icons.category_rounded, Colors.blue)),
                  ...memory.momentos.map((mom) => _buildTag(mom, Icons.favorite_rounded, Colors.pink)),
                ],
              ),
            ),
          ] else*/
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadgeForMemory(MemoryResponse memory) {
    IconData icon;
    Color color;
    String label;

    // Detectar tipo basado en la memoria individual
    final isLetter = memory.title.toLowerCase().contains('carta personal');
    final isQuestion = memory.type.toUpperCase() == 'QUESTION_RESPONSE';

    if (isQuestion) {
      icon = Icons.help_rounded;
      color = Colors.teal;
      label = 'Pregunta';
    } else if (isLetter) {
      icon = Icons.mail_rounded;
      color = Colors.purple;
      label = 'Carta';
    } else {
      icon = Icons.photo_album_rounded;
      color = AppColors.primary;
      label = 'Recuerdo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppColors.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<dynamic> files) {
    final mediaFiles = files.where((f) => f.isImage || f.isVideo).toList();
    if (mediaFiles.isEmpty) return const SizedBox();

    if (mediaFiles.length == 1) {
      return _buildSingleMedia(mediaFiles.first);
    } else if (mediaFiles.length == 2) {
      return _buildDoubleMedia(mediaFiles);
    } else {
      return _buildMultipleMedia(mediaFiles);
    }
  }

  Widget _buildSingleMedia(dynamic file) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Para videos, mostrar fondo oscuro con ícono
              if (file.isVideo)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[300]!, Colors.pink[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.videocam_rounded, size: 64, color: Colors.white70),
                  ),
                )
              else
                Image.network(
                  file.fileUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              // Overlay de play para videos
              if (file.isVideo)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleMedia(List<dynamic> files) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildMediaThumbnail(files[0])),
          const SizedBox(width: 4),
          Expanded(child: _buildMediaThumbnail(files[1])),
        ],
      ),
    );
  }

  Widget _buildMultipleMedia(List<dynamic> files) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildMediaThumbnail(files[0])),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                _buildMediaThumbnail(files[1]),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    _buildMediaThumbnail(files[2]),
                    if (files.length > 3)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${files.length - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail(dynamic file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Para videos, mostrar fondo oscuro con ícono
            if (file.isVideo)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.pink[300]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.videocam_rounded, size: 32, color: Colors.white70),
                ),
              )
            else
              Image.network(
                file.fileUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported, size: 32),
                ),
              ),
            // Overlay de play para videos
            if (file.isVideo)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_filled, size: 32, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(dynamic audioFile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio adjunto',
                  style: AppColors.labelMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  audioFile.originalFileName ?? 'audio.mp3',
                  style: AppColors.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.volume_up_rounded, color: AppColors.primary),
        ],
      ),
    );
  }

  String _formatTimeAgo(dynamic date) {
    try {
      final dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'Hace ${years} año${years > 1 ? 's' : ''}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'Hace ${months} mes${months > 1 ? 'es' : ''}';
      } else if (difference.inDays > 0) {
        return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Justo ahora';
      }
    } catch (e) {
      return '';
    }
  }

// ============ GALERÍA ============
  Widget _buildGalleryGridContent() {
    return Consumer<MemoriesByMemorialProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.memories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final memories = provider.memories.map((m) => _memoryToResponse(m)).toList();
        final allImageEntries = memories
            .expand(
              (m) => m.files
              .where((f) => f.isImage)
              .map((f) => {'file': f, 'memory': m}),
        )
            .toList();

        if (allImageEntries.isEmpty) {
          return _buildEmptyState('No hay imágenes', Icons.image_not_supported);
        }

        return GridView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: allImageEntries.length,
          itemBuilder: (context, index) {
            final entry = allImageEntries[index];

            // Extraer file y memory con tipado fuerte
            final FileResponse file = entry['file'] as FileResponse;
            final MemoryResponse memory = entry['memory'] as MemoryResponse;

            // URL segura evitando null
            final imageUrl = file.fileUrl;

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    try {
                      _navigateToMemoryDetail(memory);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error abriendo la memoria')),
                      );
                    }
                  },
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  // ============ FORMATO ============
  Widget _buildFormatTypeContent() {
    return Consumer<MemoriesByMemorialProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.memories.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final memories = provider.memories.map((m) => _memoryToResponse(m)).toList();

          // Agrupar memorias por tipo de archivo desde las memorias ya cargadas
          final Map<String, List<MemoryResponse>> memoriesByFormat = {
            'image': [],
            'video': [],
            'audio': [],
            'letter': [],
          };

          for (final memory in memories) {
            // Verificar si es una carta
            final isLetter = memory.title.toLowerCase().contains('carta personal') ||
                (memory.files.isEmpty && memory.description.isNotEmpty);

            if (isLetter) {
              memoriesByFormat['letter']!.add(memory);
            }

            // Verificar archivos
            for (final file in memory.files) {
              if (file.fileType == 'image' && !memoriesByFormat['image']!.contains(memory)) {
                memoriesByFormat['image']!.add(memory);
              }
              if (file.fileType == 'video' && !memoriesByFormat['video']!.contains(memory)) {
                memoriesByFormat['video']!.add(memory);
              }
              if (file.fileType == 'audio' && !memoriesByFormat['audio']!.contains(memory)) {
                memoriesByFormat['audio']!.add(memory);
              }
            }
          }

          // Filtrar formatos vacíos
          final hasPhotos = memoriesByFormat['image']!.isNotEmpty;
          final hasVideos = memoriesByFormat['video']!.isNotEmpty;
          final hasAudios = memoriesByFormat['audio']!.isNotEmpty;
          final hasLetters = memoriesByFormat['letter']!.isNotEmpty;

          if (!hasPhotos && !hasVideos && !hasAudios && !hasLetters) {
            return _buildEmptyState('No hay formatos', Icons.image_aspect_ratio);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                if (hasPhotos) ...[
                  _buildFormatTypeItem(
                    icon: Icons.photo_library_rounded,
                    title: 'Fotos',
                    count: '${memoriesByFormat['image']!.length} recuerdos',
                    color: Colors.blue,
                    memories: memoriesByFormat['image']!,
                    previewUrl: _getPreviewUrl(memoriesByFormat['image']!),
                  ),
                  const SizedBox(height: 12),
                ],
                if (hasVideos) ...[
                  _buildFormatTypeItem(
                    icon: Icons.videocam_rounded,
                    title: 'Videos',
                    count: '${memoriesByFormat['video']!.length} recuerdos',
                    color: Colors.green,
                    memories: memoriesByFormat['video']!,
                    previewUrl: _getPreviewUrl(memoriesByFormat['video']!),
                  ),
                  const SizedBox(height: 12),
                ],
                if (hasAudios) ...[
                  _buildFormatTypeItem(
                    icon: Icons.audiotrack_rounded,
                    title: 'Audios',
                    count: '${memoriesByFormat['audio']!.length} recuerdos',
                    color: Colors.red,
                    memories: memoriesByFormat['audio']!,
                    previewUrl: _getPreviewUrl(memoriesByFormat['audio']!),
                  ),
                  const SizedBox(height: 12),
                ],
                if (hasLetters)
                  _buildFormatTypeItem(
                    icon: Icons.mail_rounded,
                    title: 'Cartas',
                    count: '${memoriesByFormat['letter']!.length} recuerdos',
                    color: Colors.purple,
                    memories: memoriesByFormat['letter']!,
                    previewUrl: null, // Las cartas no tienen preview de imagen
                  ),
              ],
            ),
          );
        },
    );
  }

        // Helper para obtener URL de preview
  String? _getPreviewUrl(List<MemoryResponse> memories) {
      if (memories.isEmpty) return null;

      for (final memory in memories) {
        for (final file in memory.files) {
          if (file.isImage && file.fileUrl != null) {
            return file.fileUrl;
          }
        }
      }
      return null;
    }

    Widget _buildFormatTypeItem({
      required IconData icon,
      required String title,
      required String count,
      required Color color,
      required List<MemoryResponse> memories,
      String? previewUrl,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (memories.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay recuerdos en este formato')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormatTypeDetailScreen(
                  title: title,
                  memories: memories,
                  color: color,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: previewUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 36),
                    ),
                  )
                      : Icon(icon, color: color, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppColors.h6.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(count, style: AppColors.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ============ LÍNEA DE TIEMPO ============
    Widget _buildTimelineContent() {
      return Consumer<MemoriesByMemorialProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.memories.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final memories = provider.memories
                .map((m) => _memoryToResponse(m))
                .toList();
            // Filtrar memorias que son línea de tiempo
            final timelineMemories = memories.where((m) => m.esLineaTiempo == true).toList();

            if (timelineMemories.isEmpty) {
              return _buildEmptyState('No hay momentos en la línea de tiempo', Icons.timeline);
            }

            // Ordenar por fecha de la foto (o creación si no tiene photoDate)
            timelineMemories.sort((a, b) {
              final dateA = a.photoDate != null
                  ? DateTime.parse(a.photoDate.toString())
                  : DateTime.parse(a.createdDate.toString());
              final dateB = b.photoDate != null
                  ? DateTime.parse(b.photoDate.toString())
                  : DateTime.parse(b.createdDate.toString());
              return dateA.compareTo(dateB); // Orden cronológico (más antiguo primero)
            });

            return ListView.builder(
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
              itemCount: timelineMemories.length + 1, // +1 para el banner
              itemBuilder: (context, index) {
                // Primer item es el banner
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8),
                    child: AIGeneratedBanner(
                      memorialName: '',
                      accentColor: AppColors.secondary2,
                    ),
                  );
                }

                // Los demás items son las memorias
                final memoryIndex = index - 1;
                final memory = timelineMemories[memoryIndex];
                final date = memory.photoDate != null
                    ? DateTime.parse(memory.photoDate.toString())
                    : DateTime.parse(memory.createdDate.toString());
                final isLast = memoryIndex == timelineMemories.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline vertical line
                      Column(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2.5,
                                color: AppColors.primary.withOpacity(0.25),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Content card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _navigateToMemoryDetail(memory),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Año y título
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${date.year}',
                                        style: AppColors.labelLarge.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        memory.title,
                                        style: AppColors.h6.copyWith(fontSize: 17),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                // Descripción
                                if (memory.description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    memory.description,
                                    style: AppColors.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                // Contenido multimedia (igual que en actividad reciente)
                                if (memory.files.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildTimelineMediaContent(memory),
                                ],

                                // Fecha completa en gris pequeño
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatFullDate(date),
                                      style: AppColors.labelSmall.copyWith(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
      );
    }

    // Helper para mostrar contenido multimedia en línea de tiempo
    Widget _buildTimelineMediaContent(MemoryResponse memory) {
      final hasImages = memory.files.any((f) => f.isImage);
      final hasVideos = memory.files.any((f) => f.isVideo);
      final hasAudio = memory.files.any((f) => f.fileType == 'audio');

      // Si solo tiene audio, mostrar reproductor
      if (hasAudio && !hasImages && !hasVideos) {
        return _buildAudioPlayer(memory.files.firstWhere((f) => f.fileType == 'audio'));
      }

      // Si tiene imágenes o videos, mostrar grid
      if (hasImages || hasVideos) {
        return _buildMediaGrid(memory.files);
      }

      return const SizedBox.shrink();
    }

// Helper para formatear fecha completa
    String _formatFullDate(DateTime date) {
      const months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    }

    // ============ TEMÁTICAS (CATEGORÍAS) ============
    Widget _buildThemesContent() {
      return Consumer<MemoriesByMemorialProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.memories.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final memories = provider.memories
                .map((m) => _memoryToResponse(m))
                .toList();
            final Map<String, List<MemoryResponse>> memoriesByCategory = {};

            for (final memory in memories) {
              if (memory.categories != null && memory.categories!.isNotEmpty) {
                for (final categoria in memory.categories!) {
                  final categoryLower = categoria.toLowerCase();
                  if (categoryLower == 'otros') continue;

                  if (!memoriesByCategory.containsKey(categoria)) {
                    memoriesByCategory[categoria] = [];
                  }
                  if (!memoriesByCategory[categoria]!.contains(memory)) {
                    memoriesByCategory[categoria]!.add(memory);
                  }
                }
              }
            }

            if (memoriesByCategory.isEmpty) {
              return _buildEmptyState('No hay temáticas', Icons.category);
            }

            final sortedEntries = memoriesByCategory.entries.toList()
              ..sort((a, b) => b.value.length.compareTo(a.value.length));

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
              child: Column(
                children: [
                  // Banner de IA al inicio (se scrollea con el contenido)
                  AIGeneratedBanner(
                    memorialName: '',
                    accentColor: AppColors.secondary2,
                  ),

                  // Lista de categorías
                  ...sortedEntries.map((entry) {
                    final category = entry.key;
                    final categoryMemories = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildThemeItem(
                        icon: _getCategoryIcon(category),
                        title: _formatCategoryMomentName(category),
                        count: '${categoryMemories.length} recuerdo${categoryMemories.length > 1 ? 's' : ''}',
                        color: _getCategoryColor(category),
                        memories: categoryMemories,
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }
      );
    }

    Widget _buildThemeItem({
      required IconData icon,
      required String title,
      required String count,
      required Color color,
      required List<MemoryResponse> memories,
    }) {
      // Obtener URL de preview
      String? previewUrl;
      for (final memory in memories) {
        for (final file in memory.files) {
          if (file.isImage && file.fileUrl != null) {
            previewUrl = file.fileUrl;
            break;
          }
        }
        if (previewUrl != null) break;
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThemeDetailScreen(
                  title: title,
                  memories: memories,
                  color: color,
                  icon: icon,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: previewUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 36),
                    ),
                  )
                      : Icon(icon, color: color, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppColors.h6.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(count, style: AppColors.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ============ MOMENTOS ============
    Widget _buildMomentsContent() {
      return Consumer<MemoriesByMemorialProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.memories.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final memories = provider.memories
                .map((m) => _memoryToResponse(m))
                .toList();
            final Map<String, List<MemoryResponse>> memoriesByMoment = {};

            for (final memory in memories) {
              if (memory.moments != null && memory.moments!.isNotEmpty) {
                for (final momento in memory.moments!) {
                  final momentLower = momento.toLowerCase();
                  if (momentLower == 'cotidiano') continue;

                  if (!memoriesByMoment.containsKey(momento)) {
                    memoriesByMoment[momento] = [];
                  }
                  if (!memoriesByMoment[momento]!.contains(memory)) {
                    memoriesByMoment[momento]!.add(memory);
                  }
                }
              }
            }

            if (memoriesByMoment.isEmpty) {
              return _buildEmptyState('No hay momentos especiales', Icons.favorite);
            }

            final sortedEntries = memoriesByMoment.entries.toList()
              ..sort((a, b) => b.value.length.compareTo(a.value.length));

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
              child: Column(
                children: [
                  // Banner de IA al inicio (se scrollea con el contenido)
                  AIGeneratedBanner(
                    memorialName: '',
                    accentColor: AppColors.secondary2,
                  ),

                  // Lista de momentos
                  ...sortedEntries.map((entry) {
                    final moment = entry.key;
                    final momentMemories = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMomentItem(
                        icon: _getMomentIcon(moment),
                        title: _formatCategoryMomentName(moment),
                        count: '${momentMemories.length} recuerdo${momentMemories.length > 1 ? 's' : ''}',
                        color: _getMomentColor(moment),
                        memories: momentMemories,
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }
      );
    }

    Widget _buildMomentItem({
      required IconData icon,
      required String title,
      required String count,
      required Color color,
      required List<MemoryResponse> memories,
    }) {
      // Obtener URL de preview
      String? previewUrl;
      for (final memory in memories) {
        for (final file in memory.files) {
          if (file.isImage && file.fileUrl != null) {
            previewUrl = file.fileUrl;
            break;
          }
        }
        if (previewUrl != null) break;
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MomentDetailScreen(
                  title: title,
                  memories: memories,
                  color: color,
                  icon: icon,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: previewUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 36),
                    ),
                  )
                      : Icon(icon, color: color, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppColors.h6.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(count, style: AppColors.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ============ HELPERS PARA CATEGORÍAS ============
    IconData _getCategoryIcon(String category) {
      switch (category.toLowerCase()) {
        case 'familia':
          return Icons.family_restroom_rounded;
        case 'amigos':
          return Icons.groups_rounded;
        case 'pareja':
          return Icons.favorite_rounded;
        case 'infancia':
          return Icons.child_care_rounded;
        case 'juventud':
          return Icons.school_rounded;
        case 'adultez':
          return Icons.person_rounded;
        case 'viajes':
          return Icons.flight_rounded;
        case 'celebraciones':
          return Icons.celebration_rounded;
        case 'trabajo':
          return Icons.work_rounded;
        case 'comunidad':
          return Icons.people_rounded;
        case 'arte_cultura':
        case 'arte y cultura':
          return Icons.palette_rounded;
        case 'fe_espiritualidad':
        case 'fe y espiritualidad':
          return Icons.church_rounded;
        case 'salud_bienestar':
        case 'salud y bienestar':
          return Icons.favorite_border_rounded;
        case 'despedidas_duelo':
        case 'despedidas y duelo':
          return Icons.sentiment_dissatisfied_rounded;
        case 'legado':
          return Icons.auto_stories_rounded;
        default:
          return Icons.category_rounded;
      }
    }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'familia':
        return Colors.blue.shade700;
      case 'amigos':
        return Colors.green.shade700;
      case 'pareja':
        return Colors.pink.shade600;
      case 'infancia':
        return Colors.purple.shade600;
      case 'juventud':
        return Colors.indigo.shade600;
      case 'adultez':
        return Colors.blueGrey.shade700;
      case 'viajes':
        return Colors.orange.shade700;
      case 'celebraciones':
        return Colors.amber.shade700;
      case 'trabajo':
        return Colors.teal.shade700;
      case 'comunidad':
        return Colors.cyan.shade700; // cyan oscuro → raro, pero queda muy bien
      case 'arte y cultura':
        return Colors.deepPurple.shade600;
      case 'fe y espiritualidad':
        return Colors.deepOrange.shade700;
      case 'salud y bienestar':
        return Colors.lightGreen.shade700; // antes era muy claro → ahora perfecto
      case 'despedidas y duelo':
        return Colors.grey.shade700;
      case 'legado':
        return Colors.brown.shade700;
      default:
        return Colors.blueGrey.shade600;
    }
  }


    String _formatCategoryMomentName(String category) {
      // Convertir snake_case a formato legible
      final formatted = category
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');

      return formatted;
    }

    // ============ HELPERS PARA MOMENTOS ============
    IconData _getMomentIcon(String moment) {
      switch (moment.toLowerCase().replaceAll('_', ' ')) {
        case 'amor afecto':
        case 'amor':
        case 'afecto':
          return Icons.favorite_rounded;
        case 'gratitud':
          return Icons.volunteer_activism_rounded;
        case 'nostalgia':
          return Icons.history_rounded;
        case 'alegria':
        case 'alegría':
          return Icons.sentiment_very_satisfied_rounded;
        case 'tristeza':
          return Icons.sentiment_dissatisfied_rounded;
        case 'orgullo':
          return Icons.emoji_events_rounded;
        case 'superacion':
        case 'superación':
          return Icons.trending_up_rounded;
        case 'reflexion':
        case 'reflexión':
          return Icons.psychology_rounded;
        case 'fe':
          return Icons.auto_awesome_rounded;
        case 'paz':
          return Icons.spa_rounded;
        case 'asombro':
          return Icons.stars_rounded;
        default:
          return Icons.auto_awesome_outlined;
      }
    }

  Color _getMomentColor(String moment) {
    switch (moment.toLowerCase().replaceAll('_', ' ')) {
      case 'amor afecto':
      case 'amor':
      case 'afecto':
        return Colors.red.shade600;
      case 'gratitud':
        return Colors.orange.shade700;
      case 'nostalgia':
        return Colors.purple.shade600;
      case 'alegria':
        return Colors.amber.shade700; // amarillo oscuro → muy legible
      case 'tristeza':
        return Colors.blue.shade700; // azul intenso
      case 'orgullo':
        return Colors.deepOrange.shade600;
      case 'superación':
        return Colors.green.shade700; // verde oscuro y visible
      case 'reflexión':
        return Colors.indigo.shade600; // azul-morado fuerte
      case 'fe':
        return Colors.deepPurple.shade600;
      case 'paz':
        return Colors.teal.shade700;
      case 'asombro':
        return Colors.pink.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }



  // ============ HELPERS ============
    Widget _buildEmptyState(String message, IconData icon) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(message, style: AppColors.bodyLarge),
          ],
        ),
      );
    }

    // ============ IR A DETALLE DE MEMORIA ============
    void _navigateToMemoryDetail(MemoryResponse memory) {
      // Convertir MemoryResponse a Memory entity
      final memoryEntity = Memory(
        id: memory.idMemory,
        type: memory.type,
        title: memory.title,
        description: memory.description ?? '',
        photoDate: memory.photoDate != null ? DateTime.parse(memory.photoDate.toString()) : null,
        location: memory.location,
        visible: memory.visible,
        tags: memory.tags ?? [],
        associatedQuestion: memory.associatedQuestion,
        files: memory.files.map((f) => File(
          id: f.idFile,
          name: f.fileName,
          originalName: f.originalFileName,
          type: f.fileType,
          mimeType: f.mimeType,
          size: f.fileSize,
          url: f.fileUrl,
          uploadedDate: f.uploadedDate != null ? DateTime.parse(f.uploadedDate.toString()) : DateTime.now(),
        )).toList(),
        totalUsedSpace: memory.totalUsedSpace,
        createdDate: memory.createdDate != null ? DateTime.parse(memory.createdDate.toString()) : DateTime.now(),
        updateDate: memory.updateDate != null ? DateTime.parse(memory.updateDate.toString()) : null,
        latitude: memory.latitude,
        longitude: memory.longitude,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemoryDetailScreen(
            memory: memoryEntity,
            mode: MemoryMode.view,
          ),
        ),
      );
    }

    MemoryResponse _memoryToResponse(Memory memory) {
      return MemoryResponse(
        idMemory: memory.id,
        type: memory.type,
        title: memory.title,
        description: memory.description,
        photoDate: memory.photoDate,
        location: memory.location,
        visible: memory.visible,
        tags: memory.tags,
        associatedQuestion: memory.associatedQuestion,
        files: memory.files.map((f) => FileResponse(
          idFile: f.id,
          fileName: f.name,
          originalFileName: f.originalName,
          fileType: f.type,
          mimeType: f.mimeType,
          fileSize: f.size,
          fileUrl: f.url,
          uploadedDate: f.uploadedDate,
        )).toList(),
        totalUsedSpace: memory.totalUsedSpace,
        createdDate: memory.createdDate,
        updateDate: memory.updateDate,
        latitude: memory.latitude,
        longitude: memory.longitude,
        esLineaTiempo: memory.esLineaTiempo,        // USA EL VALOR DE MEMORY
        categories: memory.categories,               // USA EL VALOR DE MEMORY
        moments: memory.moments,                     // USA EL VALOR DE MEMORY
        author: memory.author != null ? UserLiteResponse(  // USA EL VALOR DE MEMORY
          idUser: memory.author!.id,
          name: memory.author!.name,
          profilePhotoUrl: memory.author!.profilePhotoUrl,
        ) : null,
      );
    }
  }

