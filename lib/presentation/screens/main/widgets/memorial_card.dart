import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'card_container.dart';

class MemorialCard extends StatelessWidget {
  final Memorial memorial;
  final VoidCallback onTap;

  const MemorialCard({
    required this.memorial,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: 120,
      child: CardContainer(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    width: double.infinity,
                    fit: BoxFit.cover,
                    image: memorial.profilePhotoBase64 != null &&
                        memorial.profilePhotoBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(memorial.profilePhotoBase64!))
                        : (memorial.profilePhotoUrl != null &&
                        memorial.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(memorial.profilePhotoUrl!)
                        : const AssetImage('assets/images/CreaPerfil.png'))
                    as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  memorial.nickname,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
