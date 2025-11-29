import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isRecording;

  const ToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isRecording
          ? BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle)
          : null,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: isRecording ? Colors.red : null),
        onPressed: onPressed,
        iconSize: 24,
      ),
    );
  }
}
