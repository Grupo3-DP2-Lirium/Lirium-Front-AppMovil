import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_lite_response.dart';

class MomentsView extends StatelessWidget {
  final Map<String, Map<String, List<MemoryLiteResponse>>> memoriesByMoment;
  final bool isLoading;
  final VoidCallback onLoad;

  const MomentsView({
    super.key,
    required this.memoriesByMoment,
    required this.isLoading,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    if (memoriesByMoment.isEmpty) {
      onLoad();
      return const Center(child: CircularProgressIndicator());
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: memoriesByMoment.entries.map((entry) {
          final moment = entry.key;
          final typeMap = entry.value;
          int totalCount = 0;
          for (var list in typeMap.values) {
            totalCount += list.length;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMomentItem(
              context,
              moment: moment,
              count: totalCount,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMomentItem(
    BuildContext context, {
    required String moment,
    required int count,
  }) {
    // Obtener preview
    String? previewUrl;
    final typeMap = memoriesByMoment[moment];
    if (typeMap != null) {
      for (var memories in typeMap.values) {
        if (memories.isNotEmpty && memories.first.firstFileUrl != null) {
          previewUrl = memories.first.firstFileUrl;
          break;
        }
      }
    }

    return Container(
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
              color: Colors.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: previewUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.favorite, color: Colors.pink, size: 32);
                      },
                    ),
                  )
                : const Icon(Icons.favorite, color: Colors.pink, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count recuerdos',
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
    );
  }
}
