import 'dart:convert';
import 'package:flutter/material.dart';

class MemorialHeader extends StatelessWidget {
  final String? coverUrl;
  final String? avatarUrl;
  final bool showSettings;
  final VoidCallback onBackPressed;
  final VoidCallback? onSettingsPressed;

  const MemorialHeader({
    super.key,
    this.coverUrl,
    this.avatarUrl,
    this.showSettings = false,
    required this.onBackPressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Header Image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getCoverImage(),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 50,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed,
            ),
          ),
        ),

        // Settings Button
        if (showSettings)
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: onSettingsPressed,
              ),
            ),
          ),
        // NOTA: La foto de perfil se renderiza en el widget principal
        // para que quede ENCIMA del contenedor blanco
      ],
    );
  }

  ImageProvider _getCoverImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return const NetworkImage(
        'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
      );
    }

    if (coverUrl!.startsWith('data:image')) {
      final base64Str = coverUrl!.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }

    return NetworkImage(coverUrl!);
  }
}
