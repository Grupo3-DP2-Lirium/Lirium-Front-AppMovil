import 'package:flutter/material.dart';

Widget storageUsageCard({
  required double usedGb,
  required double maxGb,
}) {
  final double progress = (usedGb / maxGb).clamp(0.0, 1.0);
  final bool isFull = progress >= 0.95;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFF9F6F6),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
      border: Border.all(
        color: const Color(0xFFD99293).withOpacity(.7),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Título
        const Text(
          "Almacenamiento",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Poppins",
            color: Color(0xFF303742),
          ),
        ),

        const SizedBox(height: 8),

        /// Barra de progreso
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 10,
              width: progress * double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFull
                      ? [const Color(0xFFD94E4E), const Color(0xFFE97E7E)]
                      : [const Color(0xFFD99293), const Color(0xFFEABBBB)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// Texto de GB usados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${usedGb.toStringAsFixed(1)} GB usados",
              style: const TextStyle(
                fontSize: 13,
                fontFamily: "Inter",
                color: Color(0xFF303742),
              ),
            ),
            Text(
              "${maxGb.toStringAsFixed(0)} GB",
              style: const TextStyle(
                fontSize: 13,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
                color: Color(0xFF303742),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
