import 'package:flutter/material.dart';

class PlanBenefitsList extends StatelessWidget {
  final List<String> permissions;

  const PlanBenefitsList({
    super.key,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    final benefitsMap = {
      "ACCESS_MY_PERSONAL_SPACE": "Acceso a mi espacio personal",
      "VIEW_SHARED_MEMORIALS": "Ver memoriales compartidos",
      "COLLABORATE_MEMORIALS": "Colaborar en memoriales",
      "CREATE_MEMORIALS": "Crear memoriales",
      "IA_FEATURES": "Funciones con Inteligencia Artificial",
    };

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0), // 👈 margen lateral
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Beneficios del plan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 12),
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
                          ? const Color(0xFFFFC1C1) // rosita claro
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasPermission ? Icons.check : Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12), // 👈 separa más el texto del icono
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
