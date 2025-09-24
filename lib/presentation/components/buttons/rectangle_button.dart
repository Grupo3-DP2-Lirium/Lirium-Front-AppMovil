import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class RectangleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;

  const RectangleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Necesario para que InkWell funcione
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary,
        highlightColor: AppColors.primary,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inactive)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: size * 0.3, color: Colors.grey[400] ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
