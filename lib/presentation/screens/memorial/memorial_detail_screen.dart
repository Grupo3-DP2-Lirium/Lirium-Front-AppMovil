import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborators_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/edit_memorial_screen.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/screens/memorial/services/memorial_actions.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/visualize_memories_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/format_type_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/theme_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_options_menu.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';
import 'package:flutter_frontend/data/models/memories_by_type_response.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/services/memory_service.dart';
import '../../../data/models/memory_response.dart';

// Modos de organización de galería (HU19)
enum OrganizationMode { formato, lineaDeTiempo, tematicas, momentos }

class MemorialDetailScreen extends StatefulWidget {
  final String memorialId;

  const MemorialDetailScreen({super.key, required this.memorialId});

  @override
  State<MemorialDetailScreen> createState() => _MemorialDetailScreenState();
}

class _MemorialDetailScreenState extends State<MemorialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final MemoryService _memoriesService = MemoryService();
  final MemorialService _memorialService = MemorialService();
  final MemorialActions _memorialActions = MemorialActions();
  bool _isOwner = false; // ✅ NUEVO
  bool _canEditMemorial = false;
  bool _isCollaborative = false;

  // Datos del memorial (cargados dinámicamente)
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

  // Organización de galería (HU19)
  OrganizationMode _organizationMode = OrganizationMode.formato;

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
    _tab = TabController(length: 3, vsync: this);
    _loadMemorialData();
    _loadMemories();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  int selectedTab = 0;

  /// Carga los datos del memorial desde el backend
  Future<void> _loadMemorialData() async {
    try {
      setState(() {
        isLoadingMemorial = true;
        memorialErrorMessage = null;
      });

      final memorial = await _memorialService.getMemorialById(
        widget.memorialId,
      );

      print('✅ Memorial cargado:');
      print('   - ID: ${memorial.idMemorial}');
      print('   - Nombre: ${memorial.name}');
      print('   - isOwner: ${memorial.isOwner}'); // ✅ Log crítico
      print('   - canEdit: ${memorial.canEdit}');
      print('   - isColaborative: ${memorial.isCollaborative}');

      setState(() {
        name = memorial.name;
        description = memorial.description;
        avatarUrl = memorial.profilePhoto?.fileUrl;
        _isOwner = memorial.isOwner; // ✅ CRÍTICO: Actualizar desde backend
        _canEditMemorial = memorial.canEdit ?? false;
        isLoadingMemorial = false;
        _isCollaborative = memorial.isCollaborative ?? false;
      });

      print('📊 Estado actualizado - isOwner: $_isOwner');
    } catch (e) {
      print('❌ Error cargando memorial: $e');
      setState(() {
        memorialErrorMessage = 'Error al cargar el memorial: $e';
        isLoadingMemorial = false;
      });
    }
  }

  ImageProvider _getAvatarImage() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      // Verificar si es una imagen en base64
      if (avatarUrl!.startsWith('data:image') || avatarUrl!.length > 500) {
        try {
          // Si empieza con data:image, extraer solo la parte base64
          final base64String = avatarUrl!.contains(',')
              ? avatarUrl!.split(',').last
              : avatarUrl!;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          print('Error decoding base64 image: $e');
          return const AssetImage('assets/images/CreaPerfil.png');
        }
      } else {
        // Es una URL normal
        return NetworkImage(avatarUrl!);
      }
    } else {
      // Usar imagen por defecto
      return const AssetImage('assets/images/CreaPerfil.png');
    }
  }

  ImageProvider _getCoverImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return const NetworkImage(
        'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
      );
    }

    if (coverUrl!.startsWith('data:image')) {
      final base64Str = coverUrl!.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }

    return NetworkImage(coverUrl!);
  }

  /// Carga las memorias del memorial desde el backend
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

  Future<void> _deleteMemorial(BuildContext context, String memorialId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este memorial?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false)) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await MemorialService().deleteMemorial(memorialId);

      // Actualizar provider
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      provider.eliminarMemorial(memorialId);

      Navigator.pop(context);

      // Mostrar popup de éxito
      await appPopupButtonDefault(
        context: context,
        title: "Memorial eliminado",
        message: "El memorial ha sido eliminado correctamente",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context); // cierra el popup
              Navigator.pop(context); // retrocede a la pantalla anterior
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si está cargando el memorial, mostrar indicador
    if (isLoadingMemorial) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    // Si hay error cargando el memorial
    if (memorialErrorMessage != null) {
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

    return Scaffold(
      body: Stack(
        children: [
          // Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getCoverImage(),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Settings Button
          if (_isOwner || _canEditMemorial)
            Positioned(
              top: 50,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    _showMemorialOptionsMenu(context);
                  },
                ),
              ),
            ),

          // Main Content
          Positioned(
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
                  const SizedBox(height: 60),

                  // Name
                  Text(
                    name ?? 'Cargando...',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Familia',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  // Description
                  if (description != null && description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        description!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Top Navigation Tabs
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTopTab(Icons.grid_view, 'Galería', 0),
                        _buildTopTab(
                          Icons.access_time,
                          'Actividad Reciente',
                          1,
                        ),
                        _buildTopTab(Icons.info_outline, 'Info', 2),
                      ],
                    ),
                  ),

                  // Gallery Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          _getFilterTitle(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // Organize Options Overlay
                  if (_showOrganizeOptions)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildOrganizeOption(
                                  'Actividad Reciente',
                                  'all',
                                  Icons.access_time,
                                  isFirst: true,
                                ),
                                _buildOrganizeOption(
                                  'Galería',
                                  'gallery',
                                  Icons.photo_library,
                                ),
                                _buildOrganizeOption(
                                  'Tipo de formato',
                                  'images',
                                  Icons.image,
                                ),
                                _buildOrganizeOption(
                                  'Línea de tiempo',
                                  'timeline',
                                  Icons.timeline,
                                ),
                                _buildOrganizeOption(
                                  'Temáticas',
                                  'themes',
                                  Icons.category,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    // Gallery Content
                    Expanded(child: _buildGalleryContent()),

                  // Bottom Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showOrganizeOptions = !_showOrganizeOptions;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFFF6B6B),
                                width: 2,
                              ),
                            ),
                            child: const Text(
                              'Organizar',
                              style: TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implementar crear recuerdo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Crear Recuerdo - Próximamente',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Crear Recuerdo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

          // Profile Picture
          Positioned(
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
                child: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFEBF0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFFEBF0F0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizeOption(
    String title,
    String key,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = _selectedFilter == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = key;
          _showOrganizeOptions = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB19CD9) : const Color(0xFFE1D5F0),
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(color: Colors.white, width: 1),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
            topRight: isFirst ? const Radius.circular(16) : Radius.zero,
            bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
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
            _showOrganizeOptions = false; // Cerrar opciones al cambiar tab

            // Cambiar el filtro según el tab seleccionado
            if (index == 0) {
              _selectedFilter = 'gallery';
            } else if (index == 1) {
              _selectedFilter = 'all';
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
      default:
        return 'Galería';
    }
  }

  Widget _buildGalleryContent() {
    // Renderizar contenido según la selección
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
        return _buildGalleryGridContent();
    }
  }

  Widget _buildGalleryGridContent() {
    if (isLoadingMemories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                currentPage = 0;
                _loadMemories();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay memorias para mostrar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Filtrar memorias con imágenes para la galería
    final memoriesWithImages = memories
        .where(
          (memory) =>
              memory.files.isNotEmpty &&
              memory.files.any((file) => file.isImage),
        )
        .toList();

    if (memoriesWithImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No hay imágenes para mostrar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: memoriesWithImages.length,
        itemBuilder: (context, index) {
          final memory = memoriesWithImages[index];
          final imageFile = memory.files.firstWhere((file) => file.isImage);

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageFile.downloadUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 32),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      memory.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityContent() {
    return _buildActivityTab();
  }

  Widget _buildFormatTypeContent() {
    if (_memoriesByType == null) {
      _loadMemoriesByType();
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator());
    }

    final types = _memoriesByType!.memoriesByType;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          if (types.containsKey('image'))
            _buildFormatTypeItem(
              icon: Icons.photo_library,
              title: 'Fotos',
              count: '${types['image']!.length} recuerdos',
              color: Colors.blue,
            ),
          const SizedBox(height: 12),
          if (types.containsKey('video'))
            _buildFormatTypeItem(
              icon: Icons.videocam,
              title: 'Videos',
              count: '${types['video']!.length} recuerdos',
              color: Colors.green,
            ),
          const SizedBox(height: 12),
          if (types.containsKey('audio'))
            _buildFormatTypeItem(
              icon: Icons.audiotrack,
              title: 'Audios',
              count: '${types['audio']!.length} recuerdos',
              color: Colors.red,
            ),
          const SizedBox(height: 12),
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
    if (_timelineMemories.isEmpty) {
      _loadTimelineMemories();
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _timelineMemories.length,
      itemBuilder: (context, index) {
        final memory = _timelineMemories[index];
        final date = memory.photoDate ?? memory.createdDate;
        final isLast = index == _timelineMemories.length - 1;
        final imageFile =
            memory.files.isNotEmpty && memory.files.any((f) => f.isImage)
            ? memory.files.firstWhere((f) => f.isImage)
            : null;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator (círculo y línea)
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

              // Content
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
                              memory.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Descripción
                      if (memory.description.isNotEmpty) ...[
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

                      // Imagen
                      if (imageFile != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              imageFile.downloadUrl,
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: _memoriesByCategory.entries.map((entry) {
          final category = entry.key;
          final typeMap = entry.value;
          int totalCount = 0;
          for (var list in typeMap.values) {
            totalCount += list.length;
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
    // Obtener preview image de la categoría
    String? previewUrl;
    if (_memoriesByCategory.containsKey(title)) {
      final typeMap = _memoriesByCategory[title]!;
      for (var memories in typeMap.values) {
        if (memories.isNotEmpty && memories.first.firstFileUrl != null) {
          previewUrl = memories.first.firstFileUrl;
          break;
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalle de la temática
        if (_memoriesByCategory.containsKey(title)) {
          final typeMap = _memoriesByCategory[title]!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThemeDetailScreen(
                title: title,
                memoriesByType: typeMap,
                color: color,
                icon: icon,
              ),
            ),
          );
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

  Widget _buildMomentsContent() {
    if (_memoriesByMoment.isEmpty) {
      _loadMemoriesByMoment();
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoadingSpecialData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: _memoriesByMoment.entries.map((entry) {
          final moment = entry.key;
          final typeMap = entry.value;
          int totalCount = 0;
          for (var list in typeMap.values) {
            totalCount += list.length;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildThemeItem(
              icon: Icons.favorite,
              title: moment,
              count: '$totalCount recuerdos',
              color: Colors.pink,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Métodos para cargar datos
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar tipos: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar timeline: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar momentos: $e')));
      }
    } finally {
      setState(() => _isLoadingSpecialData = false);
    }
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

  String _getMonthName(int month) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month];
  }

  // Tab 0: Actividad reciente
  Widget _buildActivityTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height - 300, // Dar altura específica
        child: Column(
          children: [
            if (isLoadingMemories)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          currentPage = 0;
                          _loadMemories();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (memories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay memorias para mostrar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final memory = memories[index];
                    return _buildMemoryPost(memory);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construye un post de memoria estilo Instagram
  Widget _buildMemoryPost(MemoryResponse memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post con información del usuario
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(memory.createdDate),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_isOwner && _canEditMemorial)
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onPressed: () {
                      _showMemorialOptionsMenu(context);
                    },
                  ),
              ],
            ),
          ),

          // Contenido de la memoria
          if (memory.files.isNotEmpty && memory.files.first.isImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(
                  memory.files.first.downloadUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Botones de interacción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.grey[700]),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: Colors.grey[700]),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, color: Colors.grey[700]),
                const Spacer(),
                if (memory.location != null)
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      Text(
                        memory.location!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Descripción
          if (memory.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                memory.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),

          // Tags
          if (memory.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 4,
                children: memory.tags
                    .map(
                      (tag) => Text(
                        '#$tag',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// Formatea la fecha para mostrar en el post
  String _formatDate(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Ahora';
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  // Tab 1: Timeline con datos reales
  Widget _buildTimelineTab() {
    print('DEBUG Timeline: Building timeline with ${memories.length} memories');

    if (isLoadingMemories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (memories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay memorias para mostrar en el timeline',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  currentPage = 0;
                  _loadMemories();
                },
                child: const Text('Recargar'),
              ),
            ],
          ),
        ),
      );
    }

    // Filtrar solo memorias con imágenes
    final memoriesWithImages = memories
        .where((memory) => memory.files.any((file) => file.isImage))
        .toList();

    print('DEBUG Timeline: Memories with images: ${memoriesWithImages.length}');

    if (memoriesWithImages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay imágenes para mostrar en el timeline',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              Text(
                'Total de memorias: ${memories.length}',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Ordenar por fecha (más reciente primero)
    memoriesWithImages.sort((a, b) {
      final dateA = a.photoDate ?? a.createdDate;
      final dateB = b.photoDate ?? b.createdDate;
      return dateB.compareTo(dateA);
    });

    // Agrupar por año
    final Map<int, List<MemoryResponse>> memoriesByYear = {};
    for (final memory in memoriesWithImages) {
      final date = memory.photoDate ?? memory.createdDate;
      final year = date.year;
      memoriesByYear.putIfAbsent(year, () => []).add(memory);
    }

    final years = memoriesByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: years.map((year) {
          final yearMemories = memoriesByYear[year]!;
          return _buildTimelineYearSection(year, yearMemories);
        }).toList(),
      ),
    );
  }

  // Construye una sección del timeline para un año específico
  Widget _buildTimelineYearSection(
    int year,
    List<MemoryResponse> yearMemories,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del año
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6366F1).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        year.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${yearMemories.length} memoria${yearMemories.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de memorias del año
          ...yearMemories.asMap().entries.map((entry) {
            final index = entry.key;
            final memory = entry.value;
            final isLast = index == yearMemories.length - 1;

            return _buildTimelineMemoryItem(memory, isLast);
          }).toList(),
        ],
      ),
    );
  }

  // Construye un item individual del timeline con datos reales
  Widget _buildTimelineMemoryItem(MemoryResponse memory, bool isLast) {
    final date = memory.photoDate ?? memory.createdDate;
    final imageFile = memory.files.firstWhere(
      (file) => file.isImage,
      orElse: () => memory.files.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 120, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha específica
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 4),

                // Título de la memoria
                Text(
                  memory.title.isNotEmpty ? memory.title : 'Sin título',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Descripción si existe
                if (memory.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    memory.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),

                // Imagen y botón "Ver más"
                Row(
                  children: [
                    // Imagen principal
                    GestureDetector(
                      onTap: () => _showImageDetail(imageFile, memory, date),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageFile.downloadUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.photo,
                                  color: Colors.grey[500],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Botón "Ver más" si hay más archivos
                    if (memory.files.length > 1) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: Color(0xFF6366F1),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+${memory.files.length - 1}',
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'más',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Tags si existen
                if (memory.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: memory.tags
                        .take(3)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar el detalle de una imagen
  void _showImageDetail(dynamic file, MemoryResponse memory, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.title.isNotEmpty
                                ? memory.title
                                : 'Sin título',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Imagen
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      file.downloadUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.error,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Descripción si existe
              if (memory.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    memory.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 2: Organizar (HU19)
  Widget _buildOrganizeTab() {
    // Selector de modo de organización
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOrgChip('Formato', OrganizationMode.formato),
                const SizedBox(width: 8),
                _buildOrgChip(
                  'Línea de tiempo',
                  OrganizationMode.lineaDeTiempo,
                ),
                const SizedBox(width: 8),
                _buildOrgChip('Temáticas', OrganizationMode.tematicas),
                const SizedBox(width: 8),
                _buildOrgChip('Momentos', OrganizationMode.momentos),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isLoadingMemories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Text(errorMessage!, style: TextStyle(color: Colors.red[600]))
          else if (memories.isEmpty)
            const Text('No hay memorias para organizar')
          else
            Expanded(child: _buildOrganizedList()),
        ],
      ),
    );
  }

  Widget _buildOrgChip(String label, OrganizationMode mode) {
    final selected = _organizationMode == mode;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _organizationMode = mode),
    );
  }

  Widget _buildOrganizedList() {
    // Construir estructura según modo
    final Map<String, List<MemoryResponse>> groups = _groupMemories();
    final groupKeys = groups.keys.toList();

    return ListView.builder(
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final key = groupKeys[index];
        final items = groups[key] ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[i];
                final url =
                    m.firstImageUrl ??
                    'https://via.placeholder.com/300x300.png?text=Memoria';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(url, fit: BoxFit.cover),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Map<String, List<MemoryResponse>> _groupMemories() {
    switch (_organizationMode) {
      case OrganizationMode.formato:
        return _groupBy(memories, (m) => _formatFromMemory(m));
      case OrganizationMode.lineaDeTiempo:
        // Agrupar por año-mes
        return _groupBy(
          memories,
          (m) {
            final d = m.photoDate ?? m.createdDate;
            return '${d.year}-${d.month.toString().padLeft(2, '0')}';
          },
          sortByKey: true,
          keyComparator: (a, b) => b.compareTo(a),
        );
      case OrganizationMode.tematicas:
        // Para cada etiqueta crear grupos; si no hay, va a 'Sin etiqueta'
        final Map<String, List<MemoryResponse>> g = {};
        for (final m in memories) {
          final tags = m.tags.isEmpty ? ['Sin etiqueta'] : m.tags;
          for (final t in tags) {
            g.putIfAbsent(t, () => []).add(m);
          }
        }
        return g;
      case OrganizationMode.momentos:
        return _groupBy(
          memories,
          (m) =>
              m.associatedQuestion ??
              (m.tags.isNotEmpty ? m.tags.first : 'General'),
        );
    }
  }

  String _formatFromMemory(MemoryResponse m) {
    // Usar field type cuando esté disponible, si no, derivar del media
    final t = m.type.toLowerCase();
    if (t.isNotEmpty) return t;
    final types = m.mediaTypes;
    if (types.length == 1) {
      switch (types.first) {
        case 'image':
          return 'foto';
        case 'video':
          return 'video';
        case 'audio':
          return 'audio';
      }
    }
    return types.isEmpty ? 'texto' : 'mixto';
  }

  Map<String, List<MemoryResponse>> _groupBy<T>(
    List<MemoryResponse> list,
    String Function(MemoryResponse) keySelector, {
    bool sortByKey = false,
    int Function(String a, String b)? keyComparator,
  }) {
    final Map<String, List<MemoryResponse>> map = {};
    for (final item in list) {
      final k = keySelector(item);
      map.putIfAbsent(k, () => []).add(item);
    }
    if (sortByKey) {
      final entries = map.entries.toList()
        ..sort(
          (a, b) => (keyComparator ?? (String a, String b) => a.compareTo(b))(
            a.key,
            b.key,
          ),
        );
      return {for (final e in entries) e.key: e.value};
    }
    return map;
  }

  /// Muestra el menú de opciones del memorial (Editar/Eliminar)
  void _showMemorialOptionsMenu(BuildContext context) {
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
            builder: (context) =>
                EditMemorialScreen(memorialId: widget.memorialId),
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
}
