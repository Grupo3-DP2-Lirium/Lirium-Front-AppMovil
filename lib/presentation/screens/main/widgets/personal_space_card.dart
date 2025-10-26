import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'card_container.dart';

class PersonalSpaceCard extends StatelessWidget {
  final VoidCallback onTap;
  const PersonalSpaceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Mi Espacio Personal', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '“Un lugar seguro para procesar y guardar tus memorias más profundas”',
              style: tt.bodyMedium?.copyWith(color: Colors.black54, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            SizedBox(height: 42, child: SecondaryButton(text: 'Ver mis reflexiones', textColor: const Color(0xFF6366F1), onPressed: onTap)),
          ],
        ),
      ),
    );
  }
}
