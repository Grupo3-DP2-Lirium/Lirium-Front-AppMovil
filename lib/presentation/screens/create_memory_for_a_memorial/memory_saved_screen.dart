import 'package:flutter/material.dart';

/// Pantalla de confirmación tras guardar una memoria.
class MemorySavedScreen extends StatelessWidget {
  final String categoryName;
  final String question;
  final String? memorialId;

  const MemorySavedScreen({super.key, required this.categoryName, required this.question, this.memorialId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Memoria guardada'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E4EA)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(Icons.house_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text('¡Tu memoria ha sido guardada!', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(
                    'Categoría: $categoryName\nPregunta: "$question"',
                    style: tt.bodyMedium?.copyWith(color: Colors.black54, height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  // Volver a seleccionar otra pregunta en la misma categoría
                  Navigator.pop(context); // cierra confirmación
                  Navigator.pop(context); // cierra answer -> vuelve al listado de preguntas de la categoría
                },
                child: const Text('Seguir añadiendo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  // Regresar al origen del flujo (podría variar)
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Finalizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

