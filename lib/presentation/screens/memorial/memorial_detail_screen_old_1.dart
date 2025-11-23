import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';
import 'package:flutter_frontend/data/models/memories_by_type_response.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/presentation/screens/memorial/edit_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborators_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_header.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_info.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/top_navigation_tabs.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/organize_options_overlay.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/bottom_action_buttons.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_options_menu.dart';
import 'package:flutter_frontend/presentation/screens/memorial/services/memorial_actions.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/gallery_grid_view.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/activity_feed_view.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/timeline_view.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/format_type_view.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/themes_view.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/moments_view.dart';

class MemorialDetailScreen extends StatefulWidget {
  final String memorialId;

  const MemorialDetailScreen({
    super.key,
    required this.memorialId,
  });

  @override
  State<MemorialDetailScreen> createState() => _MemorialDetailScreenState();
}

class _MemorialDetailScreenState extends State<MemorialDetailScreen> {
  final MemoryService _memoriesService = MemoryService();
  final MemorialService _memorialService = MemorialService();
  final MemorialActions _memorialActions = MemorialActions();

  bool _isOwner = false;
  bool _canEditMemorial = false;
  bool _isCollaborative = false;

  // Datos del memorial
  String? name;
  String? description;
  String? coverUrl;
  String? avatarUrl;
  bool isLoadingMemorial = true;
  String? memorialErrorMessage;

  // Estado para las memorias
  List<MemoryResponse> memories = [];
  bool isLoadingMemories = true;
  String? errorMessage;
  int currentPage = 0;
  final int pageSize = 10;
  bool hasMoreMemories = true;

  // Estado para el nuevo diseño
  bool _showOrganizeOptions = false;
  String _selectedFilter = 'gallery';
  int _selectedTopTab = 0; // 0: Galería, 1: Actividad Reciente, 2: Info

  // Datos para las diferentes vistas
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
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingMemorial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (memorialErrorMessage != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          MemorialHeader(
            coverUrl: coverUrl,
            avatarUrl: avatarUrl,
            showSettings: _isOwner || _canEditMemorial,
            onBackPressed: () => Navigator.pop(context),
            onSettingsPressed: _showMemorialOptionsMenu,
          ),
          _buildMainContent(),
          // Profile Picture - DEBE IR AL FINAL para estar encima del contenedor blanco
          _buildProfilePicture(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            MemorialInfo(name: name, description: description),
            TopNavigationTabs(
              selectedTab: _selectedTopTab,
              onTabSelected: _onTopTabSelected,
            ),
            _buildGalleryHeader(),
            _buildContent(),
            BottomActionButtons(
              onOrganizePressed: _toggleOrganizeOptions,
              onCreateMemoryPressed: _onCreateMemory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            _getFilterTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            color: Colors.grey[300],
            image: DecorationImage(
              image: _getAvatarImage(),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getAvatarImage() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('data:image') || avatarUrl!.length > 500) {
        try {
          final base64String = avatarUrl!.contains(',')
              ? avatarUrl!.split(',').last
              : avatarUrl!;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          return const AssetImage('assets/images/CreaPerfil.png');
        }
      } else {
        return NetworkImage(avatarUrl!);
      }
    } else {
      return const AssetImage('assets/images/CreaPerfil.png');
    }
  }

  Widget _buildContent() {
    if (_showOrganizeOptions) {
      return Expanded(
        child: OrganizeOptionsOverlay(
          selectedFilter: _selectedFilter,
          onFilterSelected: (filter) {
            setState(() {
              _selectedFilter = filter;
              _showOrganizeOptions = false;
            });
          },
        ),
      );
    }

    return Expanded(child: _buildGalleryContent());
  }

  Widget _buildGalleryContent() {
    switch (_selectedFilter) {
      case 'all':
        return ActivityFeedView(
          memories: memories,
          isLoading: isLoadingMemories,
          errorMessage: errorMessage,
          onRetry: _loadMemories,
          canEdit: _canEditMemorial || _isOwner,
        );
      case 'timeline':
        return TimelineView(
          timelineMemories: _timelineMemories,
          isLoading: _isLoadingSpecialData,
          onLoad: _loadTimelineMemories,
        );
      case 'images':
        return FormatTypeView(
          memoriesByType: _memoriesByType,
          isLoading: _isLoadingSpecialData,
          onLoad: _loadMemoriesByType,
        );
      case 'themes':
        return ThemesView(
          memoriesByCategory: _memoriesByCategory,
          isLoading: _isLoadingSpecialData,
          onLoad: _loadMemoriesByCategory,
        );
      case 'moments':
        return MomentsView(
          memoriesByMoment: _memoriesByMoment,
          isLoading: _isLoadingSpecialData,
          onLoad: _loadMemoriesByMoment,
        );
      case 'gallery':
      default:
        return GalleryGridView(
          memories: memories,
          isLoading: isLoadingMemories,
          errorMessage: errorMessage,
          onRetry: _loadMemories,
        );
    }
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

  // Métodos de navegación y UI
  void _onTopTabSelected(int index) {
    setState(() {
      _selectedTopTab = index;
      _showOrganizeOptions = false;

      if (index == 0) {
        _selectedFilter = 'gallery';
      } else if (index == 1) {
        _selectedFilter = 'all';
      }
    });
  }

  void _toggleOrganizeOptions() {
    setState(() {
      _showOrganizeOptions = !_showOrganizeOptions;
    });
  }

  void _onCreateMemory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear Recuerdo - Próximamente')),
    );
  }

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case 'all':
        return 'Actividad Reciente';
      case 'gallery':
        return 'Galería';
      case 'images':
        return 'Tipo de Formato';
      case 'timeline':
        return 'Línea de Tiempo';
      case 'themes':
        return 'Temáticas';
      case 'moments':
        return 'Momentos';
      default:
        return 'Galería';
    }
  }

  void _showMemorialOptionsMenu() {
    MemorialOptionsMenu.show(
      context,
      isOwner: _isOwner,
      canEdit: _canEditMemorial,
      isCollaborative: _isCollaborative,
      memorialId: widget.memorialId,
      memorialName: name,
      onEdit: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMemorialScreen(
              memorialId: widget.memorialId,
            ),
          ),
        ).then((value) {
          if (value == true) {
            _loadMemorialData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cambios guardados'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
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
              memorialName: name,
            ),
          ),
        );
      },
    );
  }

  // Métodos de carga de datos
  Future<void> _loadMemorialData() async {
    try {
      setState(() {
        isLoadingMemorial = true;
        memorialErrorMessage = null;
      });

      final memorial = await _memorialService.getMemorialById(widget.memorialId);

      setState(() {
        name = memorial.name;
        description = memorial.description;
        avatarUrl = memorial.profilePhoto?.fileUrl;
        _isOwner = memorial.isOwner;
        _canEditMemorial = memorial.canEdit;
        isLoadingMemorial = false;
        _isCollaborative = memorial.isCollaborative;
      });
    } catch (e) {
      setState(() {
        memorialErrorMessage = 'Error al cargar el memorial: $e';
        isLoadingMemorial = false;
      });
    }
  }

  Future<void> _loadMemories() async {
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
      setState(() {
        errorMessage = 'Error al cargar las memorias: $e';
        isLoadingMemories = false;
      });
    }
  }

  Future<void> _loadMemoriesByType() async {
    if (_memoriesByType != null) return;

    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getMemoriesByType(
        memorialId: widget.memorialId,
      );
      setState(() => _memoriesByType = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tipos: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadTimelineMemories() async {
    if (_timelineMemories.isNotEmpty) return;

    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getTimelineMemories(
        memorialId: widget.memorialId,
      );
      setState(() => _timelineMemories = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar timeline: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadMemoriesByCategory() async {
    if (_memoriesByCategory.isNotEmpty) return;

    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getMemoriesGroupedByCategory(
        memorialId: widget.memorialId,
      );
      setState(() => _memoriesByCategory = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar categorías: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }

  Future<void> _loadMemoriesByMoment() async {
    if (_memoriesByMoment.isNotEmpty) return;

    setState(() => _isLoadingSpecialData = true);
    try {
      final data = await _memoriesService.getMemoriesGroupedByMoment(
        memorialId: widget.memorialId,
      );
      setState(() => _memoriesByMoment = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar momentos: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
  }
}
