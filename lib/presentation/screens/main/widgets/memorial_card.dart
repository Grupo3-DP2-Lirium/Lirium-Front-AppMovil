import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'card_container.dart';

class MemorialCard extends StatelessWidget {
  final Memorial memorial;
  final VoidCallback onTap;
  const MemorialCard({required this.memorial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CardContainer(
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: memorial.profilePhotoBase64 != null && memorial.profilePhotoBase64!.isNotEmpty
                    ? MemoryImage(base64Decode(memorial.profilePhotoBase64!))
                    : (memorial.profilePhotoUrl != null && memorial.profilePhotoUrl!.isNotEmpty
                    ? NetworkImage(memorial.profilePhotoUrl!)
                    : const AssetImage("assets/images/default_avatar.png")) as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(memorial.name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    if (memorial.nickname != null && memorial.nickname!.isNotEmpty)
                      Text("“${memorial.nickname}”", style: tt.bodySmall?.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
