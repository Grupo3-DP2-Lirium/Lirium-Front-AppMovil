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
            child: Image.file(
              File(file.localPath!),
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.close,
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
}
