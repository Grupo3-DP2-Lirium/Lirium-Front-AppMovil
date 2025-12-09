import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class MemorialFilterButton extends StatelessWidget {
  const MemorialFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showComingSoon(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtrar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtro por memorial próximamente disponible'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
