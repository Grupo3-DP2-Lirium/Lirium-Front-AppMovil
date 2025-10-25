import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/painters/improvement_line_painter.dart';
import 'image_result_screen.dart';

/// Pantalla que muestra la animación de mejora de imagen
class ImageImprovementScreen extends StatefulWidget {
  final String imagePath;
  final String memorialId;

  const ImageImprovementScreen({
    super.key,
    required this.imagePath,
    required this.memorialId,
  });

  @override
  State<ImageImprovementScreen> createState() => _ImageImprovementScreenState();
}

class _ImageImprovementScreenState extends State<ImageImprovementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startImprovement();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _startImprovement() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _controller.forward();
    
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToResult();
    }
  }

  void _navigateToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ImageResultScreen(
          imagePath: widget.imagePath,
          memorialId: widget.memorialId
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mejorando imagen...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _buildAnimatedImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return Container(
      width: 300,
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Imagen original (más opaca)
            Image.file(
              File(widget.imagePath),
              width: 300,
              height: 400,
              fit: BoxFit.cover,
            ),
            
            // Overlay de mejora con animación
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ImprovementLinePainter(_animation.value),
                  child: Container(
                    width: 300,
                    height: 400,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}