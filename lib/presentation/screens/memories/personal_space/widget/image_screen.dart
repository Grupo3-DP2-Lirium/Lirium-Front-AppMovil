import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/reflection_model.dart';

class FullScreenImage extends StatelessWidget {
  final ReflectionFile file;

  const FullScreenImage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _buildImage(),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_outlined,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (file.localPath != null && file.localPath!.isNotEmpty) {
      return Image.file(
        File(file.localPath!),
        fit: BoxFit.contain,
      );
    }

    if (file.downloadUrl.isNotEmpty) {
      return Image.network(
        file.downloadUrl,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator(color: Colors.white);
        },
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.white, size: 50),
      );
    }

    return const Icon(Icons.broken_image, color: Colors.white, size: 50);
  }
}
