import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class TimelineDataHintBanner extends StatelessWidget {
  final Color? accentColor;

  const TimelineDataHintBanner({
    Key? key,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(
      top: 16,
      bottom: 8,),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timeline,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayúdanos a ordenar su historia',
                  style: AppColors.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completar el mes y el año de cada momento '
                      'nos permite construir una línea de tiempo clara y fiel ',
                  style: AppColors.labelSmall.copyWith(
                    color: Colors.grey[700],
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
