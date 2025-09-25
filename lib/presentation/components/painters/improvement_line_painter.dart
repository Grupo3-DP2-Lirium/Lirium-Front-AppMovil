import 'package:flutter/material.dart';

/// Custom painter que dibuja la línea de mejora de imagen
class ImprovementLinePainter extends CustomPainter {
  final double progress;

  ImprovementLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.6),
          Colors.blue.withOpacity(0.4),
          Colors.white.withOpacity(0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Línea vertical que se mueve de izquierda a derecha
    final lineWidth = 40.0;
    final currentX = size.width * progress;

    // Dibujar línea de mejora
    final rect = Rect.fromLTWH(
      currentX - lineWidth / 2,
      0,
      lineWidth,
      size.height,
    );

    canvas.drawRect(rect, paint);

    // Efecto de brillo adicional
    if (progress > 0.1) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final glowRect = Rect.fromLTWH(
        currentX - 2,
        0,
        4,
        size.height,
      );

      canvas.drawRect(glowRect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ImprovementLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}