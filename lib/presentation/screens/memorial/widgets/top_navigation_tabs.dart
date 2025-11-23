import 'package:flutter/material.dart';

class TopNavigationTabs extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabSelected;

  const TopNavigationTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55, // Reducido de 60 a 55
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildTopTab(Icons.grid_view, 'Galería', 0),
          _buildTopTab(Icons.access_time, 'Actividad Reciente', 1),
          _buildTopTab(Icons.info_outline, 'Info', 2),
        ],
      ),
    );
  }

  Widget _buildTopTab(IconData icon, String label, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                size: 22, // Reducido de 24 a 22
              ),
              const SizedBox(height: 3), // Reducido de 4 a 3
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                  fontSize: 11, // Reducido de 12 a 11
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
