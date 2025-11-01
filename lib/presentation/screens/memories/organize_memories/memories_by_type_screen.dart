import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/memories_by_type_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/presentation/components/memory_card.dart';

// Typedef para compatibilidad
typedef MemorialResponse = MemorialResponseModel;

class MemoriesByTypeScreen extends StatefulWidget {
  final MemorialResponse memorial;

  const MemoriesByTypeScreen({
    Key? key,
    required this.memorial,
  }) : super(key: key);

  @override
  State<MemoriesByTypeScreen> createState() => _MemoriesByTypeScreenState();
}

class _MemoriesByTypeScreenState extends State<MemoriesByTypeScreen> {
  final MemoryService _memoryService = MemoryService();
  
  bool _isLoading = false;
  MemoriesByTypeResponse? _response;
  String _selectedType = 'all';

  final Map<String, Map<String, dynamic>> _typeConfig = {
    'all': {
      'label': 'Ver todo',
      'icon': Icons.grid_view,
      'color': Colors.grey[600],
    },
    'image': {
      'label': 'Fotos',
      'icon': Icons.photo_library,
      'color': Colors.blue,
    },
    'video': {
      'label': 'Videos',
      'icon': Icons.videocam,
      'color': Colors.red,
    },
    'audio': {
      'label': 'Audios',
      'icon': Icons.audiotrack,
      'color': Colors.green,
    },
    'document': {
      'label': 'Documentos',
      'icon': Icons.description,
      'color': Colors.orange,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadMemoriesByType();
  }

  Future<void> _loadMemoriesByType() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _memoryService.getMemoriesByType(
        memorialId: widget.memorial.idMemorial,
      );
      
      setState(() {
        _response = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recuerdos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Por tipo de formato'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header con información del memorial
          _buildMemorialHeader(),
          
          // Botones de acción
          _buildActionButtons(),
          
          // Filtros por tipo
          _buildTypeFilters(),
          
          // Contenido principal
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
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

  Widget _buildTypeFilters() {
    if (_response == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por tipo:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Botones de filtro
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('all', 'Ver todo', Icons.grid_view, _response!.totalMemories),
              ..._response!.memoriesByType.entries.map((entry) {
                final config = _typeConfig[entry.key] ?? {
                  'label': entry.key,
                  'icon': Icons.folder,
                  'color': Colors.grey,
                };
                return _buildFilterChip(
                  entry.key,
                  config['label'],
                  config['icon'],
                  entry.value.length,
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label, IconData icon, int count) {
    final isSelected = _selectedType == type;
    final config = _typeConfig[type] ?? {'color': Colors.grey};
    final color = config['color'] as Color?;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color?.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color ?? Colors.grey) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_response == null) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final memories = _selectedType == 'all' 
        ? _response!.memoriesByType.values.expand((list) => list).toList()
        : _response!.memoriesByType[_selectedType] ?? [];

    if (memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _typeConfig[_selectedType]?['icon'] ?? Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay recuerdos de este tipo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        return MemoryCard(
          memory: memories[index],
          onTap: () {
            // TODO: Navegar a detalle del recuerdo
          },
        );
      },
    );
  }
}