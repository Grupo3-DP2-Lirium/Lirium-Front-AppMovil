import 'package:flutter/material.dart';

class PlanBenefitsList extends StatelessWidget {
  final List<String> permissions;
  final double? storageLimitGb;
  final int? maxCollaborations;
  final int? maxDocumentariesPerMonth;
  final String? supportLevel;
  final int? maxFilesPersonalSpace;

  const PlanBenefitsList({
    super.key,
    required this.permissions,
    this.storageLimitGb,
    this.maxCollaborations,
    this.maxDocumentariesPerMonth,
    this.supportLevel,
    this.maxFilesPersonalSpace
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
    final benefitsMap = {
      "ACCESS_MY_PERSONAL_SPACE": "Acceso a mi espacio personal",
      "VIEW_SHARED_MEMORIALS": "Ver memoriales compartidos",
      "COLLABORATE_MEMORIALS": "Colaborar en memoriales",
      "CREATE_MEMORIALS": "Crear memoriales",
      "IA_FEATURES": "Funciones con Inteligencia Artificial",
    };

    // Tags de atributos
    final List<Widget> tags = [];
    if (storageLimitGb != null) tags.add(_buildTag("$storageLimitGb GB"));
    if (maxCollaborations != null) tags.add(_buildTag("Colab. max: $maxCollaborations"));
    if (maxDocumentariesPerMonth != null) tags.add(_buildTag("Doc. x mes: $maxDocumentariesPerMonth"));
    if (maxFilesPersonalSpace != null) tags.add(_buildTag("Max Files x PersonalSpace: $maxFilesPersonalSpace"));
    if (supportLevel != null) tags.add(_buildTag("Soporte: $supportLevel"));

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Tags de atributos primero
          if (tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags,
            ),
          if (tags.isNotEmpty) const SizedBox(height: 12),

          // --- Título beneficios
          const Text(
            "Beneficios del plan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 12),

          // --- Lista de permisos
          ...benefitsMap.entries.map((entry) {
            final hasPermission = permissions.contains(entry.key);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: hasPermission
                          ? const Color(0xFFFFC1C1)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasPermission ? Icons.check : Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Poppins",
                        color: hasPermission
                            ? Colors.black87
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
