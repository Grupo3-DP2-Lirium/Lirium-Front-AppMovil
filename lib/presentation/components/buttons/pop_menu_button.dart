import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class PopupMenuOption {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  PopupMenuOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class CustomPopupMenu extends StatelessWidget {
  final List<PopupMenuOption> options;

  const CustomPopupMenu({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 37.2,
      height: 35.7,
      decoration: BoxDecoration(
        color: AppColors.primary2,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: PopupMenuButton<int>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 37),
        onSelected: (index) => options[index].onTap(),
        itemBuilder: (context) => options.map((option) {
          return PopupMenuItem<int>(
            value: options.indexOf(option),
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: AppColors.primary2,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(option.icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      option.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        color: AppColors.primary2,
        child: const Center(
          child: Icon(Icons.more_vert, color: Colors.white),
        ),
      ),
    );
  }
}
