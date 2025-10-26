import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'create_memory_select_type.dart';

class RowOfMemories extends StatelessWidget {
  final String tipo;
  final List<Memorial> memoriales;

  const RowOfMemories({
    super.key,
    required this.tipo,
    required this.memoriales,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: memoriales
          .map((memorial) => _buildMemorial(context, memorial))
          .toList(),
    );
  }

  Uint8List? _decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    return base64Decode(base64String);
  }

  Widget _buildMemorial(BuildContext context, Memorial memorial) {
    Uint8List? imageBytes = _decodeBase64Image(memorial.profilePhotoBase64);

    return SizedBox(
      width: 80,
      child: GestureDetector(
        onTap: () {
          // Solo pasás el ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMemorySelectType(
                memorialId: memorial.idMemorial,
              ),
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null
                  ? const Icon(Icons.image, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(memorial.name),
          ],
        ),
      ),
    );
  }
}
