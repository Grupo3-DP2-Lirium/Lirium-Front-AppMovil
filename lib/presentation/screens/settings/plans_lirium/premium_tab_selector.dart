import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class PremiumTabSelector extends StatelessWidget {
  final bool isMonthly;
  final ValueChanged<bool> onTabChanged;

  const PremiumTabSelector({
    super.key,
    required this.isMonthly,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFC4C4C4)),
      ),
      child: Row(
        children: [
          // --- Mensual ---
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(true),
              child: Container(
                decoration: BoxDecoration(
                  color: isMonthly ? AppColors.secondary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Mensual",
                  style: TextStyle(
                    color: isMonthly ? Colors.white : AppColors.primary2,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          // --- Anual ---
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(false),
              child: Container(
                decoration: BoxDecoration(
                  color: isMonthly ? Colors.transparent : AppColors.secondary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Anual",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isMonthly ? AppColors.primary2 : Colors.white,
                      ),
                    ),
                    Text(
                      "Ahorra hasta un 30%",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isMonthly ? AppColors.secondary : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}