import 'package:flutter/material.dart';

class MemorialDetailsWidget extends StatelessWidget {
  final String name;
  final String relation;
  final String birthDate;
  final String gender;
  final String nickname;

  const MemorialDetailsWidget({
    super.key,
    required this.name,
    required this.relation,
    required this.birthDate,
    required this.gender,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Nombre:", name),
            const SizedBox(height: 13),
            _detailRow("Relación contigo:", relation),
            const SizedBox(height: 13),
            _detailRow("Fecha de nacimiento:", birthDate),
            const SizedBox(height: 13),
            _detailRow("Género:", gender),
            const SizedBox(height: 13),
            _detailRow("Apodo:", nickname),
          ],
        ),
      )
      )
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: Color(0xFF20242B),
            ),
          ),
        ),
      ],
    );
  }
}
