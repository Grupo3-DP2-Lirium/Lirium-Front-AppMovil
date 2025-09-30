import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  const HomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: tt.titleLarge?.copyWith(color: Colors.black87),
                children: [
                  const TextSpan(text: 'Hola, '),
                  TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Text('¿Qué momento especial quieres guardar hoy?', style: tt.labelSmall?.copyWith(color: Colors.black54)),
          ],
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}
