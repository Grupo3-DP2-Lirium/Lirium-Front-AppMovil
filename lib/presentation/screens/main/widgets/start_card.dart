import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'card_container.dart';

class StartCard extends StatelessWidget {
  final VoidCallback onCreate;
  const StartCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: cs.primary.withOpacity(.25), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text('¡Empezar es fácil!', style: tt.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer memorial y construye un legado que perdure para siempre',
            style: tt.bodyMedium?.copyWith(color: Colors.black54, height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(height: 52, child: PrimaryButton(text: 'Crear mi primer memorial', onPressed: onCreate, isFullWidth: true)),
        ],
      ),
    );
  }
}
