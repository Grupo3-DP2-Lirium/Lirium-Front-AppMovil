import 'package:flutter/material.dart';

class OrganizeOptionsOverlay extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const OrganizeOptionsOverlay({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              _buildOrganizeOption('Actividad Reciente', 'all', Icons.access_time, isFirst: true),
              _buildOrganizeOption('Galería', 'gallery', Icons.photo_library),
              _buildOrganizeOption('Tipo de formato', 'images', Icons.image),
              _buildOrganizeOption('Línea de tiempo', 'timeline', Icons.timeline),
              _buildOrganizeOption('Temáticas', 'themes', Icons.category, isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizeOption(String title, String key, IconData icon, {bool isFirst = false, bool isLast = false}) {
    final isSelected = selectedFilter == key;

    return GestureDetector(
      onTap: () => onFilterSelected(key),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB19CD9) : const Color(0xFFE1D5F0),
          border: Border(
            bottom: isLast ? BorderSide.none : const BorderSide(color: Colors.white, width: 1),
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
}
