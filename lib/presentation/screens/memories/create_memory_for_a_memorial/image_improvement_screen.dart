import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/image_service.dart';
import 'package:flutter_frontend/presentation/components/painters/improvement_line_painter.dart';
import 'image_result_screen.dart';

/// Pantalla que muestra la animación de mejora de imagen (genérica)
class ImageImprovementScreen extends StatefulWidget {
  final String imagePath;
  
  const ImageImprovementScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageImprovementScreen> createState() => _ImageImprovementScreenState();
}

class _ImageImprovementScreenState extends State<ImageImprovementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ImageService _imageService = ImageService();
  
  List<int>? _enhancedImageBytes;
  String? _errorMessage;
  bool _isProcessing = true;

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
    _controller.repeat();
    
    try {
      print('🔧 Iniciando mejora de imagen...');
      final imageFile = File(widget.imagePath);
      final enhancedBytes = await _imageService.enhanceImage(imageFile);
      
      print('✅ Imagen mejorada recibida (${enhancedBytes.length} bytes)');
      
      if (mounted) {
        setState(() {
          _enhancedImageBytes = enhancedBytes;
          _isProcessing = false;
        });
        
        await _controller.forward();
        await Future.delayed(const Duration(milliseconds: 800));
        _navigateToResult();
      }
    } catch (e) {
      print('❌ Error al mejorar imagen: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isProcessing = false;
        });
        _controller.stop();
        _showErrorDialog();
      }
    }
  }

  // ✅ CORREGIDO: Usar push en lugar de pushReplacement
  Future<void> _navigateToResult() async {
    if (_enhancedImageBytes == null) return;
    
    print('📱 Navegando a ImageResultScreen...');
    
    // CAMBIO CRÍTICO: Usar push() en lugar de pushReplacement()
    final String? resultPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageResultScreen(
          originalImagePath: widget.imagePath,
          enhancedImageBytes: _enhancedImageBytes!,
        ),
      ),
    );
    
    print('✅ ImageImprovementScreen recibió resultado: $resultPath');
    
    // Si recibimos un resultado, propagarlo hacia atrás
    if (mounted && resultPath != null) {
      Navigator.pop(context, resultPath);
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error al mejorar imagen'),
        content: Text(_errorMessage ?? 'Error desconocido'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a pantalla anterior
            },
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _errorMessage = null;
                _isProcessing = true;
              });
              _startImprovement();
            },
            child: const Text('Reintentar'),
          ),
        ],
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
              Text(
                _isProcessing 
                    ? 'Mejorando imagen...'
                    : _errorMessage != null
                        ? 'Error'
                        : 'Imagen mejorada',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _buildAnimatedImage(),
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
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
            Image.file(
              File(widget.imagePath),
              width: 300,
              height: 400,
              fit: BoxFit.cover,
            ),
            
            if (_isProcessing)
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