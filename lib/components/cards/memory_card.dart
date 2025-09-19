import 'package:flutter/material.dart';

class MemoryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? time;
  final int? imageCount;
  final VoidCallback? onTap;
  final bool isGridView;

  const MemoryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    this.imageCount,
    this.onTap,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: isGridView
            ? EdgeInsets.zero
            : const EdgeInsets.only(bottom: 16),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library, size: 40, color: Colors.grey),
                  if (imageCount != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$imageCount fotos',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (time != null) ...[
          const SizedBox(height: 4),
          Text(time!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (time != null)
              Text(
                time!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
        if (imageCount != null) ...[
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    '$imageCount fotos',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
