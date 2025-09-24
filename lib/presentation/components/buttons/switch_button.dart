import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class BooleanSelectorSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BooleanSelectorSwitch({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Switch(
          value: value,
          activeTrackColor: AppColors.primary, // color de la pista activa
          inactiveThumbColor: Colors.white, // bolita inactiva
          inactiveTrackColor: AppColors.inactive, // pista inactiva
          onChanged: onChanged,
        ),
      ],
    );
  }
}
