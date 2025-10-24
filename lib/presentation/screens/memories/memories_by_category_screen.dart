import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';

class MemoriesByCategoryScreen extends StatefulWidget {
  final MemorialResponseModel memorial;

  const MemoriesByCategoryScreen({
    Key? key,
    required this.memorial,
  }) : super(key: key);

  @override
  State<MemoriesByCategoryScreen> createState() =>
      _MemoriesByCategoryScreenState();
}

class _MemoriesByCategoryScreenState extends State<MemoriesByCategoryScreen> {
  final MemoryService _memoryService = MemoryService();
  bool _isLoading = false;
  Map<String, Map<String, List<MemoryLiteResponse>>> _groupedMemories = {};

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);

    try {
      final response = await _memoryService.getMemoriesGroupedByCategory(
        memorialId: widget.memorial.idMemorial,
      );

      setState(() {
        _groupedMemories = response;
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
        title: const Text('Recuerdos por Categoría'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedMemories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay recuerdos organizados por categoría',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _groupedMemories.keys.length,
                  itemBuilder: (context, index) {
                    final category = _groupedMemories.keys.elementAt(index);
                    final typeMap = _groupedMemories[category]!;

                    return _buildCategorySection(category, typeMap);
                  },
                ),
    );
  }

  Widget _buildCategorySection(
      String category, Map<String, List<MemoryLiteResponse>> typeMap) {
    // Contar total de memorias en esta categoría
    int totalCount = 0;
    typeMap.values.forEach((list) => totalCount += list.length);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$totalCount recuerdo${totalCount != 1 ? 's' : ''}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.red[400],
          child: const Icon(Icons.category, color: Colors.white, size: 20),
        ),
        children: [
          ...typeMap.entries.map((entry) {
            final type = entry.key;
            final memories = entry.value;

            if (memories.isEmpty) return const SizedBox.shrink();

            return _buildTypeSection(type, memories);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTypeSection(String type, List<MemoryLiteResponse> memories) {
    IconData icon;
    String label;

    switch (type.toLowerCase()) {
      case 'image':
        icon = Icons.image;
        label = 'Imágenes';
        break;
      case 'video':
        icon = Icons.videocam;
        label = 'Videos';
        break;
      case 'audio':
        icon = Icons.audiotrack;
        label = 'Audios';
        break;
      case 'text':
        icon = Icons.text_fields;
        label = 'Textos';
        break;
      default:
        icon = Icons.insert_drive_file;
        label = type;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.red[400]),
              const SizedBox(width: 8),
              Text(
                '$label (${memories.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: memories.length,
              itemBuilder: (context, index) {
                return _buildMemoryCard(memories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(MemoryLiteResponse memory) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: memory.firstFileUrl != null
                  ? DecorationImage(
                      image: NetworkImage(memory.firstFileUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: memory.firstFileUrl == null
                ? Center(
                    child: Icon(
                      _getIconForType(memory.fileType),
                      size: 32,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          // Título
          Text(
            memory.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;

    if (fileType.contains('image')) return Icons.image;
    if (fileType.contains('video')) return Icons.videocam;
    if (fileType.contains('audio')) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }
}
