import 'package:flutter/material.dart';

Widget currentPlanCard({
  required bool hasPlan,
  required String planName,
  required String storage,
  String? startDate,
  String? renewalDate,
  String? endDate, // <- nueva fecha opcional
}) {
  final bool isFree = !hasPlan || planName.toUpperCase().contains("FREE") || planName.toUpperCase().contains("DESCUBRE");

  // Colores según tipo de plan
  final gradientColors = isFree
      ? [const Color(0xFFFBE9E7), const Color(0xFFFFF3F0)]
      : [const Color(0xFFD99293), const Color(0xFFB76E79)];

  final icon = isFree ? Icons.card_giftcard : Icons.workspace_premium;

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
              "Tu plan actual",
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
        Text(
          isFree ? "Plan Descubre Lirium" : planName,
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w700,
            color: isFree ? const Color(0xFF303742) : Colors.white,
          ),
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
              if (renewalDate != null && renewalDate != "-" && renewalDate!.isNotEmpty)
                _planDateColumn("Día de Renovación", renewalDate)
              else if (endDate != null && endDate != "-" && endDate!.isNotEmpty)
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
