import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';

class ThemeDetailScreen extends StatefulWidget {
  final String title;
  final Map<String, List<MemoryLiteResponse>> memoriesByType;
  final Color color;
  final IconData icon;

  const ThemeDetailScreen({
    Key? key,
    required this.title,
    required this.memoriesByType,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  String _selectedType = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros por tipo
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos'),
                const SizedBox(width: 8),
                if (widget.memoriesByType.containsKey('image'))
                  _buildFilterChip('Foto'),
                const SizedBox(width: 8),
                if (widget.memoriesByType.containsKey('video'))
                  _buildFilterChip('Video'),
                const SizedBox(width: 8),
                if (widget.memoriesByType.containsKey('audio'))
                  _buildFilterChip('Audio'),
                const SizedBox(width: 8),
                if (widget.memoriesByType.containsKey('document'))
                  _buildFilterChip('Carta'),
              ],
            ),
          ),
          
          // Grid de imágenes
          Expanded(
            child: _buildMemoriesGrid(),
          ),
          
          // Botón Crear Recuerdo
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crear Recuerdo - Próximamente')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
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
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMemoriesGrid() {
    List<MemoryLiteResponse> filteredMemories = [];
    
    if (_selectedType == 'Todos') {
      // Mostrar todas las memorias
      widget.memoriesByType.values.forEach((list) {
        filteredMemories.addAll(list);
      });
    } else {
      // Filtrar por tipo
      final typeKey = _selectedType.toLowerCase() == 'foto' ? 'image'
          : _selectedType.toLowerCase() == 'video' ? 'video'
          : _selectedType.toLowerCase() == 'audio' ? 'audio'
          : 'document';
      
      if (widget.memoriesByType.containsKey(typeKey)) {
        filteredMemories = widget.memoriesByType[typeKey]!;
      }
    }

    if (filteredMemories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay recuerdos en esta categoría',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
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
        childAspectRatio: 1.0,
      ),
      itemCount: filteredMemories.length,
      itemBuilder: (context, index) {
        final memory = filteredMemories[index];
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (memory.firstFileUrl != null)
                Image.network(
                  memory.firstFileUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: widget.color.withOpacity(0.1),
                      child: Icon(
                        widget.icon,
                        size: 48,
                        color: widget.color,
                      ),
                    );
                  },
                )
              else
                Container(
                  color: widget.color.withOpacity(0.1),
                  child: Icon(
                    widget.icon,
                    size: 48,
                    color: widget.color,
                  ),
                ),
              
              // Overlay con título
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
    );
  }
}
