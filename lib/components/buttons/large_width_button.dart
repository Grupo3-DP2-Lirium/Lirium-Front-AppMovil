import 'package:flutter/material.dart';

class LargeWidthButton extends StatelessWidget {

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LargeWidthButton({
    super.key,
    this.label = "Texto por defecto",
    this.onPressed = _defaultOnPressed,
    this.backgroundColor,
    this.foregroundColor = Colors.black
  });

  static void _defaultOnPressed() {
    debugPrint('Botón presionado (función por defecto)');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
