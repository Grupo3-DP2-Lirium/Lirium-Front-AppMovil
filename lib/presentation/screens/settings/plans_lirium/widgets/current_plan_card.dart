import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

Widget currentPlanCard({
  required bool hasPlan,
  required String planName,
  required String storage,
  String? startDate,
  String? renewalDate,
  String? endDate,
  bool isExtra = false,
  VoidCallback? onCancelExtra,
}) {
  final bool isFree = !hasPlan || planName.toUpperCase().contains("FREE") || planName.toUpperCase().contains("DESCUBRE");

  // Colores según tipo de plan
  final gradientColors = isExtra
      ? [AppColors.primary2, const Color(0xFF586A99)]
      : isFree
      ? [const Color(0xFFFBE9E7), const Color(0xFFFFF3F0)]
      : [AppColors.primary, const Color(0xFFE18394)];

  final icon = isExtra
      ? Icons.cloud_upload
      : isFree
      ? Icons.card_giftcard
      : Icons.workspace_premium;

  final titleText = isExtra ? "Espacio extra" : "Tu plan actual";

  final planDisplayed = isExtra ? planName : (isFree ? "Plan Descubre Lirium" : planName);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header con ícono y nombre del plan
        Row(
          children: [
            Icon(icon, color: isFree ? const Color(0xFFD99293) : Colors.white, size: 26),
            const SizedBox(width: 8),
            Text(
              titleText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins",
                color: isFree ? const Color(0xFF7A7A7A) : Colors.white70,
              ),
            ),
            const Spacer(),

            /// Badge de almacenamiento
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                storage,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF303742),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// Nombre del plan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              planDisplayed,
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                color: isFree ? const Color(0xFF303742) : Colors.white,
              ),
            ),
            if (isExtra && onCancelExtra != null)
              GestureDetector(
                onTap: onCancelExtra,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),

        if (isFree) ...[
          const SizedBox(height: 5),
          const Text(
            "Incluido con tu cuenta de Lirium",
            style: TextStyle(
              fontSize: 13,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              color: Color(0xFF787B80),
            ),
          ),
        ],

        if (!isFree) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _planDateColumn("Inicio de Suscripción", startDate),
              if (renewalDate != null && renewalDate != "-" && renewalDate.isNotEmpty)
                _planDateColumn("Día de Renovación", renewalDate)
              else if (endDate != null && endDate != "-" && endDate.isNotEmpty)
                _planDateColumn("Día de Cierre", endDate)
              else
                _planDateColumn("Día de Renovación", "-"),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _planDateColumn(String label, String? date) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        date ?? "-",
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  );
}
