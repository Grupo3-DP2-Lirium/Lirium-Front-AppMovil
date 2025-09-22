import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/buttons/primary_button.dart';
import 'package:flutter_frontend/screens/memories/new_personal_memory_screen.dart';
import '../../components/buttons/secondary_button.dart';
import '../../components/cards/memory_card.dart'; // usa tu card existente

class PersonalSpaceScreen extends StatelessWidget {
  const PersonalSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Mock de datos agrupados por mes
    final Map<String, List<_PersonalMemory>> data = {
      'Septiembre': [
        _PersonalMemory(
          date: DateTime(2025, 9, 14),
          title: 'Cena familiar con mamá',
          description: '“Fue especial porque recordamos a papá.”',
          time: '14/09/2025',
          imageCount: 4,
          hasImage: true,
        ),
        _PersonalMemory(
          date: DateTime(2025, 9, 14),
          title: 'Nueva meta personal',
          description: 'Hoy decidí empezar a correr en las mañanas.',
          time: '14/09/2025',
        ),
        _PersonalMemory(
          date: DateTime(2025, 9, 5),
          title: 'Un día de música',
          description: 'Grabé una canción que me salió del corazón.',
          time: '05/09/2025',
          hasAudio: true,
        ),
      ],
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mi espacio personal', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Pregunta + CTA “Empezar a escribir…”
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text('¿Cómo estás hoy?',
                    style: tt.displaySmall?.copyWith(color: Colors.black45)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 240,
                  child: PrimaryButton(
                    text: 'Empezar a escribir...',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewPersonalMemoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Secciones por mes
          for (final entry in data.entries) ...[
            Text(entry.key,
                style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 12),
            for (final m in entry.value) ...[
              _TimelineDecor(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: MemoryCard(
                    // Usa tu componente existente (props del ejemplo de Timeline)
                    title: m.title,
                    subtitle: m.description,
                    time: m.time, // arriba a la izquierda
                    imageCount: m.hasImage ? (m.imageCount ?? 1) : 0,
                    onTap: () {
                      // TODO: navegar a detalle de memoria personal
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TimelineDecor extends StatelessWidget {
  // Decora con una línea vertical de colores (sutil), como en el mock
  final Widget child;
  const _TimelineDecor({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 4, height: 18, color: const Color(0xFF52D6A5)),
            Container(width: 4, height: 4, color: Colors.transparent),
            Container(width: 4, height: 18, color: const Color(0xFF8E8CF7)),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}

class _PersonalMemory {
  final DateTime date;
  final String title;
  final String description;
  final String time;
  final bool hasImage;
  final bool hasAudio;
  final int? imageCount;

  _PersonalMemory({
    required this.date,
    required this.title,
    required this.description,
    required this.time,
    this.hasImage = false,
    this.hasAudio = false,
    this.imageCount,
  });
}
