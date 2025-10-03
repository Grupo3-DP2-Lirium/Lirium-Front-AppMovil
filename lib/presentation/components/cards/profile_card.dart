import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String description;
  final String? linkType;
  final String? profilePhotoBase64;
  final String? profilePhotoUrl;
  final bool isShared;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.name,
    required this.description,
    this.linkType,
    this.profilePhotoBase64,
    this.profilePhotoUrl,
    this.isShared = false,
    required this.onTap,
  });

  ImageProvider _getImage() {
    if (profilePhotoBase64 != null && profilePhotoBase64!.isNotEmpty) {
      return MemoryImage(base64Decode(profilePhotoBase64!));
    } else if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(profilePhotoUrl!);
    } else {
      return const AssetImage('assets/images/CreaPerfil.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: _getImage(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nombre, descripción y tipo de vínculo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (linkType != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      linkType!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Iconos a la derecha
            Column(
              children: [
                Icon(
                  isShared ? Icons.groups_2 : Icons.person_outline,
                  color: Colors.black54,
                  size: 24,
                ),
                const SizedBox(height: 16),
                const Icon(Icons.chevron_right, color: Colors.black38, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
