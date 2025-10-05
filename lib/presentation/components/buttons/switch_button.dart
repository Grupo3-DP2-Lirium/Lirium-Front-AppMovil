import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class BooleanSelectorSwitch extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool withBackground;

  const BooleanSelectorSwitch({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.withBackground = true, // por defecto con fondo gris
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: withBackground
          ? BoxDecoration(
        color: AppColors.inactive,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inactive),
      )
          : null, // 🔹 si no quieres fondo, no aplicamos decoración
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label + subtítulo opcional
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ]
            ],
          ),

          // Switch
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}