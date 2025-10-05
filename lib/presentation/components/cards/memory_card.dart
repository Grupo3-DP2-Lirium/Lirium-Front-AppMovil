import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;
  final bool isGridView;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: isGridView ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGridView ? _buildGridContent() : _buildListContent(),
      ),
    );
  }

  /// Muestra la imagen del primer archivo si existe
  Widget _buildImagePreview() {
    final firstImage = memory.images.isNotEmpty ? memory.images.first : null;

    if (firstImage == null) {
      // No hay imagen → placeholder
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.photo_library, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "Sin imagen",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Si tiene URL
    if (firstImage.url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          firstImage.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    // Fallback
    return const Center(
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildImagePreview(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          memory.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (memory.photoDate != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatDate(memory.photoDate!),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                memory.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (memory.photoDate != null)
              Text(
                _formatDate(memory.photoDate!),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        if (memory.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            memory.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
        if (memory.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: _buildImagePreview(),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
