import 'package:flutter/material.dart';
import 'plan_benefits_list.dart';

import 'package:flutter/material.dart';
import 'plan_benefits_list.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool recommended;
  final bool isSelected;
  final VoidCallback onTap;
  final List<String> permissions;

  // ✅ Nuevos atributos
  final int? storageLimitGb;
  final int? maxCollaborations;
  final int? maxDocumentariesPerMonth;
  final String? supportLevel;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.recommended,
    required this.isSelected,
    required this.onTap,
    this.permissions = const [],
    this.storageLimitGb,
    this.maxCollaborations,
    this.maxDocumentariesPerMonth,
    this.supportLevel,
  });

  Widget _buildTag(String text, {Color color = const Color(0xFFFC7171)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tags = [];
    if (storageLimitGb != null) tags.add(_buildTag("$storageLimitGb GB"));
    if (maxCollaborations != null) tags.add(_buildTag("Colab. max: $maxCollaborations"));
    if (maxDocumentariesPerMonth != null) tags.add(_buildTag("Doc. x mes: $maxDocumentariesPerMonth"));
    if (supportLevel != null) tags.add(_buildTag("Soporte: $supportLevel"));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFC7171) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título y etiqueta recomendado
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF303742),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (recommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC7171),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Recomendado",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // --- Precio
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFFC7171),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // --- Descripción
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            // --- Tags de atributos
            Wrap(
              children: tags,
            ),
            const SizedBox(height: 12),
            // --- Beneficios
            PlanBenefitsList(permissions: permissions),
          ],
        ),
      ),
    );
  }
}