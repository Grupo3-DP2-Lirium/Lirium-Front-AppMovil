import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/models/memories_by_type_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_filter_chips.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/format_type_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/theme_detail_screen.dart';

class MemoriesTab extends StatefulWidget {
  final String memorialId;
  final MemoryService memoriesService;

  const MemoriesTab({
    super.key,
    required this.memorialId,
    required this.memoriesService,
  });

  @override
  State<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'all';

  // Datos de memorias
  List<MemoryResponse> memories = [];
  bool isLoadingMemories = true;
  String? errorMessage;
  int currentPage = 0;
  final int pageSize = 10;
  bool hasMoreMemories = true;

  // Datos organizados
  Map<String, Map<String, List<MemoryLiteResponse>>> _memoriesByCategory = {};
  List<MemoryResponse> _timelineMemories = [];
  MemoriesByTypeResponse? _memoriesByType;
  bool _isLoadingSpecialData = false;

  // Filtros disponibles
  final List<FilterChipData> _filters = const [
    FilterChipData(key: 'all', label: 'Recientes', icon: Icons.access_time_rounded),
    FilterChipData(key: 'gallery', label: 'Galería', icon: Icons.photo_library_rounded),
    FilterChipData(key: 'images', label: 'Formato', icon: Icons.image_rounded),
    FilterChipData(key: 'timeline', label: 'Línea de Tiempo', icon: Icons.timeline_rounded),
    FilterChipData(key: 'themes', label: 'Temáticas', icon: Icons.category_rounded),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoadingMemories = true;
        errorMessage = null;
      });

      final response = await widget.memoriesService.listMemories(
        memorialId: widget.memorialId,
        page: currentPage,
        size: pageSize,
      );

      if (!mounted) return;

      setState(() {
        if (currentPage == 0) {
          memories = response.content;
        } else {
          memories.addAll(response.content);
        }
        hasMoreMemories = (response.number + 1) < response.totalPages;
        isLoadingMemories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar las memorias: $e';
        isLoadingMemories = false;
      });
    }
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
        Expanded(child: _buildFilteredContent()),
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
      default:
        return _buildActivityContent();
    }
  }

  // ============ RECIENTES (FEED STYLE) ============
  Widget _buildActivityContent() {
    if (isLoadingMemories) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (memories.isEmpty) {
      return _buildEmptyState('No hay recuerdos', Icons.photo_library_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: memories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildMemoryFeedCard(memories[index]),
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
                //_buildTypeBadge(memory.type),
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
          /*if (memory.categories.isNotEmpty || memory.moments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...memory.categories.map((cat) => _buildTag(cat, Icons.category_rounded, Colors.blue)),
                  ...memory.moments.map((mom) => _buildTag(mom, Icons.favorite_rounded, Colors.pink)),
                ],
              ),
            ),
          ] else */
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    IconData icon;
    Color color;
    String label;

    switch (type.toUpperCase()) {
      case 'SPONTANEOUS':
        icon = Icons.flash_on_rounded;
        color = Colors.orange;
        label = 'Espontáneo';
        break;
      case 'LETTER':
        icon = Icons.mail_rounded;
        color = Colors.purple;
        label = 'Carta';
        break;
      case 'QUESTION':
        icon = Icons.help_rounded;
        color = Colors.teal;
        label = 'Pregunta';
        break;
      default:
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
              Image.network(
                file.downloadUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
              if (file.isVideo)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
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
            Image.network(
              file.downloadUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[100],
                child: const Icon(Icons.image_not_supported, size: 32),
              ),
            ),
            if (file.isVideo)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
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

  Widget _buildTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppColors.labelSmall.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    final memoriesWithImages = memories.where((m) => m.files.any((f) => f.isImage)).toList();
    if (memoriesWithImages.isEmpty) {
      return _buildEmptyState('No hay imágenes', Icons.image_not_supported);
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: memoriesWithImages.length,
      itemBuilder: (context, index) {
        final imageFile = memoriesWithImages[index].files.firstWhere((f) => f.isImage);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageFile.downloadUrl, fit: BoxFit.cover),
        );
      },
    );
  }

  // ============ FORMATO ============
  Widget _buildFormatTypeContent() {
    if (_memoriesByType == null) {
      _loadMemoriesByType();
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final Map<String, List<dynamic>> types =
        (_memoriesByType?.memoriesByType as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, List<dynamic>.from(v))) ??
            {};

    if (types.isEmpty) {
      return _buildEmptyState('No hay formatos', Icons.image_aspect_ratio);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          if (types.containsKey('image')) ...[
            _buildFormatTypeItem(
              icon: Icons.photo_library_rounded,
              title: 'Fotos',
              count: '${types['image']!.length} recuerdos',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
          ],
          if (types.containsKey('video')) ...[
            _buildFormatTypeItem(
              icon: Icons.videocam_rounded,
              title: 'Videos',
              count: '${types['video']!.length} recuerdos',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
          ],
          if (types.containsKey('audio')) ...[
            _buildFormatTypeItem(
              icon: Icons.audiotrack_rounded,
              title: 'Audios',
              count: '${types['audio']!.length} recuerdos',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
          ],
          if (types.containsKey('document'))
            _buildFormatTypeItem(
              icon: Icons.description_rounded,
              title: 'Documentos',
              count: '${types['document']!.length} recuerdos',
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildFormatTypeItem({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    String? previewUrl;
    if (_memoriesByType != null) {
      final typeKey = title.toLowerCase() == 'fotos'
          ? 'image'
          : title.toLowerCase() == 'videos'
          ? 'video'
          : title.toLowerCase() == 'audios'
          ? 'audio'
          : 'document';

      final memoriesOfType = _memoriesByType!.memoriesByType[typeKey];
      if (memoriesOfType != null && memoriesOfType.isNotEmpty) {
        final firstMemory = memoriesOfType.first;
        if (firstMemory.files.isNotEmpty) {
          previewUrl = firstMemory.files.first.downloadUrl;
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final typeKey = title.toLowerCase() == 'fotos'
              ? 'image'
              : title.toLowerCase() == 'videos'
              ? 'video'
              : title.toLowerCase() == 'audios'
              ? 'audio'
              : 'document';

          if (_memoriesByType != null) {
            final memoriesOfType = _memoriesByType!.memoriesByType[typeKey];
            if (memoriesOfType != null && memoriesOfType.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormatTypeDetailScreen(
                    title: title,
                    memories: memoriesOfType,
                    color: color,
                  ),
                ),
              );
            }
          }
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
    if (_timelineMemories.isEmpty) {
      _loadTimelineMemories();
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
      itemCount: _timelineMemories.length,
      itemBuilder: (context, index) {
        final memory = _timelineMemories[index];
        final date = _toDateTime(memory.photoDate ?? memory.createdDate);
        final isLast = index == _timelineMemories.length - 1;
        final imageFile = _firstImageFile(memory.files);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${date.year}', style: AppColors.h5.copyWith(color: AppColors.primary)),
                          const SizedBox(width: 8),
                          Text('-', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(memory.title ?? '', style: AppColors.h6.copyWith(fontSize: 17)),
                          ),
                        ],
                      ),
                      if ((memory.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(memory.description, style: AppColors.bodyMedium),
                      ],
                      if (imageFile != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              imageFile.downloadUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[100],
                                child: const Icon(Icons.image_not_supported, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ TEMÁTICAS ============
  Widget _buildThemesContent() {
    if (_memoriesByCategory.isEmpty) {
      _loadMemoriesByCategory();
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final entries = _memoriesByCategory.entries.toList();

    if (entries.isEmpty) {
      return _buildEmptyState('No hay temáticas', Icons.category);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        children: entries.map((entry) {
          final category = entry.key;
          final typeMap = entry.value;
          int totalCount = 0;
          for (var list in typeMap.values) {
            totalCount += (list?.length ?? 0);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildThemeItem(
              icon: _getCategoryIcon(category),
              title: category,
              count: '$totalCount recuerdos',
              color: _getCategoryColor(category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeItem({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    String? previewUrl;
    if (_memoriesByCategory.containsKey(title)) {
      final typeMap = _memoriesByCategory[title]!;
      for (var memoriesList in typeMap.values) {
        if (memoriesList != null && memoriesList.isNotEmpty) {
          final first = memoriesList.first;
          if (first != null) {
            if ((first as dynamic).firstFileUrl != null) {
              previewUrl = (first as dynamic).firstFileUrl as String?;
              break;
            }
            if ((first as dynamic).files != null && ((first as dynamic).files as List).isNotEmpty) {
              final files = (first as dynamic).files as List;
              for (final f in files) {
                try {
                  final isImage = (f as dynamic).isImage;
                  if (isImage == true) {
                    previewUrl = (f as dynamic).downloadUrl as String?;
                    break;
                  }
                } catch (_) {
                  previewUrl = (f as dynamic).downloadUrl as String?;
                  if (previewUrl != null) break;
                }
              }
              if (previewUrl != null) break;
            }
          }
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!_memoriesByCategory.containsKey(title)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay recuerdos en esta temática')),
            );
            return;
          }
          final typeMap = _memoriesByCategory[title]!;
          try {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ThemeDetailScreen(
                  title: title,
                  memoriesByType: typeMap,
                  color: color,
                  icon: icon,
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error abriendo temática')),
            );
          }
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

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  FileResponse? _firstImageFile(List<FileResponse>? files) {
    if (files == null) return null;
    for (final f in files) {
      if (f.isImage == true) return f;
    }
    return null;
  }

  Future<void> _loadMemoriesByType() async {
    if (_memoriesByType != null) return;
    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await widget.memoriesService.getMemoriesByType(memorialId: widget.memorialId);
      setState(() => _memoriesByType = data);
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadTimelineMemories() async {
    if (_timelineMemories.isNotEmpty) return;
    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await widget.memoriesService.getTimelineMemories(memorialId: widget.memorialId);
      setState(() => _timelineMemories = data);
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadMemoriesByCategory() async {
    if (_memoriesByCategory.isNotEmpty) return;
    setState(() => _isLoadingSpecialData = true);
    try {
      final data =
      await widget.memoriesService.getMemoriesGroupedByCategory(memorialId: widget.memorialId);
      setState(() => _memoriesByCategory = data);
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'familia':
        return Icons.family_restroom_rounded;
      case 'celebraciones':
        return Icons.celebration_rounded;
      case 'viajes':
        return Icons.travel_explore_rounded;
      case 'trabajo':
        return Icons.work_rounded;
      case 'hobbies':
        return Icons.sports_esports_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'familia':
        return Colors.blue;
      case 'celebraciones':
        return Colors.purple;
      case 'viajes':
        return Colors.orange;
      case 'trabajo':
        return Colors.green;
      case 'hobbies':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}