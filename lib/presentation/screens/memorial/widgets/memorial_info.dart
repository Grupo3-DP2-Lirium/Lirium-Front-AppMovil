import 'package:flutter/material.dart';

class MemorialInfo extends StatelessWidget {
  final String? name;
  final String? description;

  const MemorialInfo({
    super.key,
    this.name,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 70), // Aumentado para que la foto no tape el nombre

        // Name
        Text(
          name ?? 'Cargando...',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6), // Reducido de 8 a 6

        // Subtitle
        const Text(
          'Familia',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        
        // Description
        if (description != null && description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              description!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: 8), // Reducido de 12 a 8
      ],
    );
  }
}
