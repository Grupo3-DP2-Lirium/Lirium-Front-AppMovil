import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborative_memorials/collaborators_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/edit_memorial_screen.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_actions.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_details_state.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_details_widget.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/visualize_memories_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/format_type_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/theme_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_options_menu.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';
import 'package:flutter_frontend/data/models/memories_by_type_response.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/services/memory_service.dart';
import '../../../data/models/memory_response.dart';
import '../../../domain/entities/memory.dart';
import '../../../providers/memory_provider.dart';
import '../../../providers/plan_provider.dart';
import '../memories/create_memory_for_a_memorial/create_memory_select_type.dart';
import '../memories/create_memory_for_a_memorial/create_memory_to_memorial.dart';
import '../settings/plans_lirium/get_premium_screen.dart';

class MemorialDetailScreen extends StatefulWidget {
  final String memorialId;

  const MemorialDetailScreen({super.key, required this.memorialId});

  @override
  State<MemorialDetailScreen> createState() => _MemorialDetailScreenState();
}

class _MemorialDetailScreenState extends State<MemorialDetailScreen> {
  final MemoryService _memoriesService = MemoryService();
  final MemorialService _memorialService = MemorialService();
  final MemorialActions _memorialActions = MemorialActions();
  final ScrollController _scrollController = ScrollController();

  // Estado principal
  MemorialDetailsState _detailsState = MemorialDetailsState();
  String? coverUrl;

  // Estado de carga
  bool isLoadingMemorial = true;
  String? memorialErrorMessage;

  // Estado de memorias
  List<MemoryResponse> memories = [];
  bool isLoadingMemories = true;
  String? errorMessage;
  int currentPage = 0;
  final int pageSize = 10;
  bool hasMoreMemories = true;

  // UI State
  bool _isHeaderCollapsed = false;
  String _selectedFilter = 'all';
  int _selectedTopTab = 0;

  // Datos organizados
  Map<String, Map<String, List<MemoryLiteResponse>>> _memoriesByCategory = {};
  Map<String, Map<String, List<MemoryLiteResponse>>> _memoriesByMoment = {};
  List<MemoryResponse> _timelineMemories = [];
  MemoriesByTypeResponse? _memoriesByType;
  bool _isLoadingSpecialData = false;

  @override
  void initState() {
    super.initState();
    _loadMemorialData();
    _loadMemories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Colapsar header cuando scroll > 100
    final shouldCollapse = _scrollController.offset > 100;
    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = shouldCollapse);
    }
  }

  Future<void> _loadMemorialData() async {
    try {
      setState(() {
        isLoadingMemorial = true;
        memorialErrorMessage = null;
      });

      final memorial = await _memorialService.getMemorialById(widget.memorialId);
      if (!mounted) return;

      setState(() {
        _detailsState = MemorialDetailsState.fromResponse(memorial);
        isLoadingMemorial = false;
      });
    } catch (e) {
      print('❌ Error cargando memorial: $e');
      setState(() {
        memorialErrorMessage = 'Error al cargar el memorial: $e';
        isLoadingMemorial = false;
      });
    }
  }

  Future<void> _loadMemories() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoadingMemories = true;
        errorMessage = null;
      });

      final response = await _memoriesService.listMemories(
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

  ImageProvider _getAvatarImage() {
    final avatarUrl = _detailsState.profilePhotoUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image') || avatarUrl.length > 500) {
        try {
          final base64String = avatarUrl.contains(',') ? avatarUrl.split(',').last : avatarUrl;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          return const AssetImage('assets/images/CreaPerfil.png');
        }
      } else {
        return NetworkImage(avatarUrl);
      }
    }
    return const AssetImage('assets/images/CreaPerfil.png');
  }

  ImageProvider _getCoverImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return const NetworkImage('https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800');
    }
    if (coverUrl!.startsWith('data:image')) {
      final base64Str = coverUrl!.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }
    return NetworkImage(coverUrl!);
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final hasPremiumPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

    if (!subProvider.isLoaded || isLoadingMemorial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    if (memorialErrorMessage != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenido principal con scroll
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header expandible
              _buildSliverHeader(),

              // Tabs pegados
              _buildSliverPersistentTabs(),

              // Contenido de los tabs
              SliverFillRemaining(
                child: _buildTabContent(),
              ),
            ],
          ),

          // Botones flotantes en la parte inferior
          _buildFloatingButtons(hasPremiumPermission),

          // Botón de configuración
          if (_detailsState.isOwner || _detailsState.canEdit)
            _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isHeaderCollapsed ? Colors.transparent : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isHeaderCollapsed ? Colors.black : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: _isHeaderCollapsed
            ? Text(
          _detailsState.name ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            Image(
              image: _getCoverImage(),
              fit: BoxFit.cover,
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),     // oscuro arriba
                    Colors.transparent,                // transparente en la parte media-alta
                    Colors.transparent,                // transparencia para suavizar
                    Colors.white.withOpacity(1),    // blanco casi sólido abajo
                  ],
                  stops: const [0.0, 0.1, 0.2, 0.50],

                ),
                //color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),

            // Profile info
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      image: DecorationImage(
                        image: _getAvatarImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    _detailsState.name ?? 'Cargando...',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Relation
                  Text(
                    _detailsState.relation,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),

                  // Description (if exists and not too long)
                  if (_detailsState.description != null &&
                      _detailsState.description!.isNotEmpty) //&&
                      //_detailsState.description!.length < 200)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Text(
                        _detailsState.description!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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

  Widget _buildSliverPersistentTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Tabs principales
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildTopTab(Icons.grid_view, 'Recuerdos', 0),
                    _buildTopTab(Icons.movie_filter_outlined, 'Videos', 1),
                    _buildTopTab(Icons.info_outline, 'Info', 2),
                  ],
                ),
              ),

              // Filtros de organización (solo visible en tab Recuerdos)
              if (_selectedTopTab == 0)
                Container(
                  height: 50,
                  color: Colors.grey[50],
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('Recientes', 'all', Icons.access_time),
                      _buildFilterChip('Galería', 'gallery', Icons.photo_library),
                      _buildFilterChip('Formato', 'images', Icons.image),
                      _buildFilterChip('Línea de Tiempo', 'timeline', Icons.timeline),
                      _buildFilterChip('Temáticas', 'themes', Icons.category)
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(IconData icon, String label, int index) {
    final isSelected = _selectedTopTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTopTab = index;
            if (index == 0) _selectedFilter = 'all';
            if (index == 1) _selectedFilter = 'videos';
            if (index == 2) _selectedFilter = 'details';
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, IconData icon) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() => _selectedFilter = key);
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF6366F1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedFilter == 'details') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MemorialDetailsWidget(
          name: _detailsState.name,
          relation: _detailsState.relation,
          birthDate: _detailsState.birthDate,
          gender: _detailsState.gender,
          nickname: _detailsState.nickname,
        ),
      );
    }

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
      case 'videos':
        return _buildVideosContent();
      default:
        return _buildActivityContent();
    }
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: _isHeaderCollapsed ? Colors.white : const Color(0xFF6366F1),
          shape: BoxShape.circle,
          boxShadow: _isHeaderCollapsed
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: _isHeaderCollapsed ? const Color(0xFF6366F1) : Colors.white,
          ),
          onPressed: () => _showMemorialOptionsMenu(context),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons(bool hasPremiumPermission) {
    return Positioned(
      bottom: 40,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () {
          if (hasPremiumPermission) {
            _goToCreateMemory();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
            );
          }
        },
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear Recuerdo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                memorialErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadMemorialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de contenido
  Widget _buildActivityContent() {
    if (isLoadingMemories) {
      return const Center(child: CircularProgressIndicator());
    }
    if (memories.isEmpty) {
      return _buildEmptyState('No hay memorias para mostrar', Icons.photo_library_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 40, left: 16, right: 16),
      itemCount: memories.length,
      itemBuilder: (context, index) => _buildMemoryCard(memories[index]),
    );
  }

  Widget _buildMemoryCard(MemoryResponse memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (memory.files.isNotEmpty && memory.files.first.isImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Image.network(
                  memory.files.first.downloadUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (memory.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    memory.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGridContent() {
    final memoriesWithImages = memories.where((m) => m.files.any((f) => f.isImage)).toList();
    if (memoriesWithImages.isEmpty) {
      return _buildEmptyState('No hay imágenes', Icons.image_not_supported);
    }
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 16, left: 16, right: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: memoriesWithImages.length,
      itemBuilder: (context, index) {
        final imageFile = memoriesWithImages[index].files.firstWhere((f) => f.isImage);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageFile.downloadUrl, fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildVideosContent() {
    final memoriesWithVideos = memories.where((m) => m.files.any((f) => f.isVideo)).toList();
    if (memoriesWithVideos.isEmpty) {
      return _buildEmptyState('No hay videos', Icons.videocam_off);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 16, left: 16, right: 16),
      itemCount: memoriesWithVideos.length,
      itemBuilder: (context, index) => _buildMemoryCard(memoriesWithVideos[index]),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  // Mantener métodos existentes para formato, timeline y temáticas
  Widget _buildFormatTypeContent() {
    // Si no hay datos, los cargamos y mostramos loader
    if (_memoriesByType == null) {
      _loadMemoriesByType();
      return const Center(child: CircularProgressIndicator());
    }

    // Si está cargando datos especiales (guard)
    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator());
    }

    // Aseguramos la estructura y evitamos nulls
    final Map<String, List<dynamic>> types =
        (_memoriesByType?.memoriesByType as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, List<dynamic>.from(v))) ??
            {};

    if (types.isEmpty) {
      return _buildEmptyState('No hay formatos', Icons.image_aspect_ratio);
    }

    // Usamos SingleChildScrollView para que no haya conflicto con el CustomScrollView padre
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (types.containsKey('image'))
            _buildFormatTypeItem(
              icon: Icons.photo_library,
              title: 'Fotos',
              count: '${types['image']!.length} recuerdos',
              color: Colors.blue,
            ),
          if (types.containsKey('image')) const SizedBox(height: 12),

          if (types.containsKey('video'))
            _buildFormatTypeItem(
              icon: Icons.videocam,
              title: 'Videos',
              count: '${types['video']!.length} recuerdos',
              color: Colors.green,
            ),
          if (types.containsKey('video')) const SizedBox(height: 12),

          if (types.containsKey('audio'))
            _buildFormatTypeItem(
              icon: Icons.audiotrack,
              title: 'Audios',
              count: '${types['audio']!.length} recuerdos',
              color: Colors.red,
            ),
          if (types.containsKey('audio')) const SizedBox(height: 12),

          if (types.containsKey('document'))
            _buildFormatTypeItem(
              icon: Icons.description,
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
    // Obtener la primera memoria del tipo para mostrar preview
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

    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalle del tipo
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Preview image o icono
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: previewUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  previewUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(icon, color: color, size: 32);
                  },
                ),
              )
                  : Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTimelineContent() {
    // Si no hay datos, los cargamos y mostramos loader
    if (_timelineMemories.isEmpty) {
      _loadTimelineMemories();
      return const Center(child: CircularProgressIndicator());
    }

    // Guard mientras se cargan sub-datos
    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator());
    }

    // Helper local para convertir a DateTime de forma segura
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

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 140, top: 8, left: 24, right: 24),
      itemCount: _timelineMemories.length,
      itemBuilder: (context, index) {
        final memory = _timelineMemories[index];
        final date = _toDateTime(memory.photoDate ?? memory.createdDate);
        final isLast = index == _timelineMemories.length - 1;

        // buscar primer archivo de imagen (si existe)
        final imageFile = _firstImageFile(memory.files);


        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de timeline (círculo + línea)
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Contenido de la memoria
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Año y título
                      Row(
                        children: [
                          Text(
                            '${date.year}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              memory.title ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Descripción
                      if ((memory.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          memory.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],

                      // Imagen (si existe)
                      if (imageFile != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              imageFile.downloadUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
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


  Widget _buildThemesContent() {
    if (_memoriesByCategory.isEmpty) {
      _loadMemoriesByCategory();
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = _memoriesByCategory.entries.toList();

    if (entries.isEmpty) {
      return _buildEmptyState('No hay temáticas', Icons.category);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
      child: Column(
        children: entries.map((entry) {
          final category = entry.key;
          final typeMap = entry.value; // Map<String, List<MemoryLiteResponse>>
          // Contar total de recuerdos en la categoría
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
    // Obtener preview image de la categoría (de forma defensiva)
    String? previewUrl;
    if (_memoriesByCategory.containsKey(title)) {
      final typeMap = _memoriesByCategory[title]!;
      // typeMap: Map<String, List<MemoryLiteResponse>>
      for (var memoriesList in typeMap.values) {
        if (memoriesList != null && memoriesList.isNotEmpty) {
          final first = memoriesList.first;
          // diferentes modelos pueden tener first.firstFileUrl o first.files
          if (first != null) {
            // Caso 1: propiedad directa firstFileUrl (ya usabas esto antes)
            if ((first as dynamic).firstFileUrl != null) {
              previewUrl = (first as dynamic).firstFileUrl as String?;
              break;
            }
            // Caso 2: lista de files con downloadUrl
            if ((first as dynamic).files != null && ((first as dynamic).files as List).isNotEmpty) {
              final files = (first as dynamic).files as List;
              for (final f in files) {
                // intentar usar isImage o cualquier campo que indique imagen
                try {
                  final isImage = (f as dynamic).isImage;
                  if (isImage == true) {
                    previewUrl = (f as dynamic).downloadUrl as String?;
                    break;
                  }
                } catch (_) {
                  // si estructura distinta, intenta downloadUrl directamente
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
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          debugPrint('Theme tapped: $title');
          if (!_memoriesByCategory.containsKey(title)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay recuerdos en esta temática')));
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
          } catch (e, st) {
            debugPrint('Error navegando a ThemeDetailScreen: $e\n$st');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error abriendo temática')));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: previewUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    previewUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(icon, color: color, size: 32),
                  ),
                )
                    : Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _loadMemoriesByType() async {
    if (_memoriesByType != null) return;
    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getMemoriesByType(memorialId: widget.memorialId);
      setState(() => _memoriesByType = data);
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadTimelineMemories() async {
    if (_timelineMemories.isNotEmpty) return;
    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getTimelineMemories(memorialId: widget.memorialId);
      setState(() => _timelineMemories = data);
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadMemoriesByCategory() async {
    if (_memoriesByCategory.isNotEmpty) return;
    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getMemoriesGroupedByCategory(memorialId: widget.memorialId);
      setState(() => _memoriesByCategory = data);
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _goToCreateMemory() async {
    final prov = context.read<MemoryProvider>();
    final createdMemory = await Navigator.push<Memory>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMemorySelectType(
          memorialId: _detailsState.idMemorial,
          memorialName: _detailsState.name,
        ),
      ),
    );
    if (createdMemory != null) {
      prov.agregarMemoria(createdMemory);
    }
  }

  void _showMemorialOptionsMenu(BuildContext context) {
    MemorialOptionsMenu.show(
      context,
      isOwner: _detailsState.isOwner,
      canEdit: _detailsState.canEdit,
      isCollaborative: _detailsState.isCollaborative,
      memorialId: widget.memorialId,
      memorialName: _detailsState.name,
      onEdit: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMemorialScreen(memorialId: widget.memorialId),
          ),
        ).then((value) {
          if (value == true) {
            _loadMemorialData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cambios guardados'), backgroundColor: Colors.green),
            );
          }
        });
      },
      onDelete: () async {
        await _memorialActions.deleteMemorial(context, widget.memorialId);
      },
      onShare: () async {
        await _memorialActions.shareMemorial(context, widget.memorialId);
      },
      onManageCollaborators: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollaboratorsScreen(
              memorialId: widget.memorialId,
              memorialName: _detailsState.name,
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'familia':
        return Icons.family_restroom;
      case 'celebraciones':
        return Icons.celebration;
      case 'viajes':
        return Icons.travel_explore;
      case 'trabajo':
        return Icons.work;
      case 'hobbies':
        return Icons.sports_esports;
      default:
        return Icons.category;
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

// Delegate para mantener los tabs pegados
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 60.0; // Solo tabs principales

  @override
  double get maxExtent => 110.0; // Tabs + filtros

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
  return true;
  }
}