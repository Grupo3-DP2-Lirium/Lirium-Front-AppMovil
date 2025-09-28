import 'package:flutter/material.dart';

/// Botón personalizado para responder preguntas
class AnswerButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color? textColor;
  final VoidCallback? onPressed;

  const AnswerButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final buttonTextColor = textColor ?? Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: buttonTextColor,
          size: 24,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: buttonTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color,
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}