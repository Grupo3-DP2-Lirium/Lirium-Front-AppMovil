import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/presentation/components/memory_card.dart';
import 'package:flutter_frontend/presentation/screens/memories/memories_by_type_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/memories_by_category_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/memories_by_moment_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/timeline_memories_screen.dart';

// Typedef para compatibilidad
typedef MemorialResponse = MemorialResponseModel;

class VisualizeMemoriesScreen extends StatefulWidget {
  final MemorialResponse memorial;

  const VisualizeMemoriesScreen({
    Key? key,
    required this.memorial,
  }) : super(key: key);

  @override
  State<VisualizeMemoriesScreen> createState() => _VisualizeMemoriesScreenState();
}

class _VisualizeMemoriesScreenState extends State<VisualizeMemoriesScreen> {
  final MemoryService _memoryService = MemoryService();

  String _selectedFilter = 'all';
  final String _selectedSort = 'date';
  bool _isLoading = false;
  List<MemoryResponse> _memories = [];

  final List<Map<String, dynamic>> _filterOptions = [
    {'key': 'all', 'label': 'Ver todo', 'icon': Icons.grid_view},
    {'key': 'images', 'label': 'Por tipo de formato', 'icon': Icons.photo_library},
    {'key': 'timeline', 'label': 'Por línea de tiempo', 'icon': Icons.timeline},
    {'key': 'themes', 'label': 'Por temáticas', 'icon': Icons.category},
    {'key': 'moments', 'label': 'Por sus momentos', 'icon': Icons.favorite},
  ];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    _loadAllMemories();
  }

  Future<void> _loadAllMemories() async {
    setState(() => _isLoading = true);

    try {
      final response = await _memoryService.listMemories(
        memorialId: widget.memorial.idMemorial,
        page: 0,
        size: 50,
      );

      setState(() {
        _memories = response.content;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar recuerdos: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Visualizar Recuerdos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implementar configuraciones
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con información del memorial
          _buildMemorialHeader(),

          // Botones de acción
          _buildActionButtons(),

          // Botón organizar
          _buildOrganizeButton(),

          // Opciones de filtro
          _buildFilterOptions(),

          // Lista de recuerdos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMemoriesContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemorialHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Foto de perfil
          CircleAvatar(
            radius: 30,
            backgroundImage: widget.memorial.profilePhoto?.fileUrl != null
                ? NetworkImage(widget.memorial.profilePhoto!.fileUrl)
                : null,
            child: widget.memorial.profilePhoto?.fileUrl == null
                ? Text(
              widget.memorial.name.isNotEmpty
                  ? widget.memorial.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
                : null,
          ),
          const SizedBox(width: 16),

          // Información del memorial
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memorial.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Última actualización hace 2 días',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar seguir
              },
              icon: const Icon(Icons.favorite_border, size: 18),
              label: const Text('0 seguidores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar compartir
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Compartir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          _showOrganizeOptions();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'ORGANIZAR',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Organizar por:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option['key'];

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = option['key'];
                      });
                      _handleFilterChange(option['key']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red[400] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            option['icon'],
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesContent() {
    if (_memories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay recuerdos para mostrar',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    switch (_selectedFilter) {
      case 'images':
        return _buildTypeFilteredView();
      case 'timeline':
        return _buildTimelineView();
      case 'themes':
        return _buildThemesView();
      case 'moments':
        return _buildMomentsView();
      default:
        return _buildGridView();
    }
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        return MemoryCard(memory: _memories[index]);
      },
    );
  }

  Widget _buildTypeFilteredView() {
    // TODO: Implementar vista por tipos
    return _buildGridView();
  }

  Widget _buildTimelineView() {
    // TODO: Implementar vista de timeline
    return _buildGridView();
  }

  Widget _buildThemesView() {
    // TODO: Implementar vista por temas
    return _buildGridView();
  }

  Widget _buildMomentsView() {
    // TODO: Implementar vista por momentos
    return _buildGridView();
  }

  void _handleFilterChange(String filterKey) {
    switch (filterKey) {
      case 'all':
        _loadAllMemories();
        break;
      case 'images':
      // Navegar a la pantalla de tipos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoriesByTypeScreen(memorial: widget.memorial),
          ),
        );
        break;
      case 'timeline':
        _loadMemoriesByTimeline();
        break;
      case 'themes':
        _loadMemoriesByThemes();
        break;
      case 'moments':
        _loadMemoriesByMoments();
        break;
    }
  }

  Future<void> _loadMemoriesByType() async {
    setState(() => _isLoading = true);

    try {
      final response = await _memoryService.getMemoriesByType(
        memorialId: widget.memorial.idMemorial,
      );

      // Convertir la respuesta agrupada a una lista plana para mostrar
      List<MemoryResponse> allMemories = [];
      response.memoriesByType.values.forEach((memories) {
        allMemories.addAll(memories);
      });

      setState(() {
        _memories = allMemories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recuerdos por tipo: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMemoriesByTimeline() async {
    // Navegar a la pantalla de timeline
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimelineMemoriesScreen(memorial: widget.memorial),
      ),
    );
  }

  Future<void> _loadMemoriesByThemes() async {
    // Navegar a la pantalla de categorías
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoriesByCategoryScreen(memorial: widget.memorial),
      ),
    );
  }

  Future<void> _loadMemoriesByMoments() async {
    // Navegar a la pantalla de momentos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoriesByMomentScreen(memorial: widget.memorial),
      ),
    );
  }

  void _showOrganizeOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Organizar recuerdos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Opciones de organización
            ..._filterOptions.map((option) => ListTile(
              leading: Icon(option['icon'], color: Colors.red[400]),
              title: Text(option['label']),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedFilter = option['key'];
                });
                _handleFilterChange(option['key']);
              },
            )).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}