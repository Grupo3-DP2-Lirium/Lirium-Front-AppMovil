import 'package:flutter/material.dart';

class DateLabel extends StatelessWidget {
  final String text;
  const DateLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(text, style: tt.labelSmall?.copyWith(color: Colors.black54)),
    );
  }
}
