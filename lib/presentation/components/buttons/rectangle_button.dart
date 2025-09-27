import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class RectangleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;
  final bool isSelected; // <-- Nuevo parámetro

  const RectangleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 140,
    this.isSelected = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? AppColors.primary : Colors.grey[200];
    final iconColor = isSelected ? Colors.white : Colors.grey[400];
    final labelColor = isSelected ? Colors.white : Colors.grey[400];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.3),
        highlightColor: AppColors.primary.withOpacity(0.1),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.inactive),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: size * 0.3, color: iconColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
