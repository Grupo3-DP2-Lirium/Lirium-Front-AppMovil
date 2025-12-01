import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class MemorialFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final List<FilterChipData> filters;

  const MemorialFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter.key;

          return GestureDetector(
            onTap: () => onFilterChanged(filter.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary2.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.secondary2.withOpacity(0.4) : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 18,
                    color: isSelected ? AppColors.secondary2 : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.label,
                    style: AppColors.labelMedium.copyWith(
                      fontSize: 13,
                      color: isSelected ? AppColors.secondary2 : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterChipData {
  final String key;
  final String label;
  final IconData icon;

  const FilterChipData({
    required this.key,
    required this.label,
    required this.icon,
  });
}