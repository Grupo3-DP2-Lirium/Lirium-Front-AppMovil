import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memories_by_type_response.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/format_type_detail_screen.dart';

class FormatTypeView extends StatelessWidget {
  final MemoriesByTypeResponse? memoriesByType;
  final bool isLoading;
  final VoidCallback onLoad;

  const FormatTypeView({
    super.key,
    required this.memoriesByType,
    required this.isLoading,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    if (memoriesByType == null) {
      onLoad();
      return const Center(child: CircularProgressIndicator());
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final types = memoriesByType!.memoriesByType;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          if (types.containsKey('image'))
            _buildFormatTypeItem(
              context,
              icon: Icons.photo_library,
              title: 'Fotos',
              count: '${types['image']!.length} recuerdos',
              color: Colors.blue,
              typeKey: 'image',
            ),
          const SizedBox(height: 12),
          if (types.containsKey('video'))
            _buildFormatTypeItem(
              context,
              icon: Icons.videocam,
              title: 'Videos',
              count: '${types['video']!.length} recuerdos',
              color: Colors.green,
              typeKey: 'video',
            ),
          const SizedBox(height: 12),
          if (types.containsKey('audio'))
            _buildFormatTypeItem(
              context,
              icon: Icons.audiotrack,
              title: 'Audios',
              count: '${types['audio']!.length} recuerdos',
              color: Colors.red,
              typeKey: 'audio',
            ),
          const SizedBox(height: 12),
          if (types.containsKey('document'))
            _buildFormatTypeItem(
              context,
              icon: Icons.description,
              title: 'Documentos',
              count: '${types['document']!.length} recuerdos',
              color: Colors.orange,
              typeKey: 'document',
            ),
        ],
      ),
    );
  }

  Widget _buildFormatTypeItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String count,
    required Color color,
    required String typeKey,
  }) {
    // Obtener preview
    String? previewUrl;
    final memoriesOfType = memoriesByType!.memoriesByType[typeKey];
    if (memoriesOfType != null && memoriesOfType.isNotEmpty) {
      final firstMemory = memoriesOfType.first;
      if (firstMemory.files.isNotEmpty) {
        previewUrl = firstMemory.files.first.downloadUrl;
      }
    }

    return GestureDetector(
      onTap: () {
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
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
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
}
