import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';
import 'package:flutter_frontend/presentation/screens/memories/organize_memories/theme_detail_screen.dart';

class ThemesView extends StatelessWidget {
  final Map<String, Map<String, List<MemoryLiteResponse>>> memoriesByCategory;
  final bool isLoading;
  final VoidCallback onLoad;

  const ThemesView({
    super.key,
    required this.memoriesByCategory,
    required this.isLoading,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    if (memoriesByCategory.isEmpty) {
      onLoad();
      return const Center(child: CircularProgressIndicator());
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: memoriesByCategory.entries.map((entry) {
          final category = entry.key;
          final typeMap = entry.value;
          int totalCount = 0;
          for (var list in typeMap.values) {
            totalCount += list.length;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildThemeItem(
              context,
              category: category,
              typeMap: typeMap,
              totalCount: totalCount,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeItem(
    BuildContext context, {
    required String category,
    required Map<String, List<MemoryLiteResponse>> typeMap,
    required int totalCount,
  }) {
    final icon = _getCategoryIcon(category);
    final color = _getCategoryColor(category);

    // Obtener preview image
    String? previewUrl;
    for (var memories in typeMap.values) {
      if (memories.isNotEmpty && memories.first.firstFileUrl != null) {
        previewUrl = memories.first.firstFileUrl;
        break;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThemeDetailScreen(
              title: category,
              memoriesByType: typeMap,
              color: color,
              icon: icon,
            ),
          ),
        );
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
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCount recuerdos',
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
