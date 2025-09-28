import 'package:flutter/material.dart';
import 'card_container.dart';

class MiniTimelineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const MiniTimelineCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return CardContainer(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: Color(0xFFEDEDED)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: tt.titleMedium?.copyWith(color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: tt.bodySmall?.copyWith(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
