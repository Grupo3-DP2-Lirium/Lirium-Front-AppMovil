// widgets/memorial_grid.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';

class MemorialesHeader extends StatelessWidget {
  final VoidCallback onSeeAll;
  const MemorialesHeader({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Memoriales',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Ver todo',
                  style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                Icon(Icons.visibility, size: 18, color: cs.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MemorialGrid extends StatelessWidget {
  final List<Memorial> memorials;
  final void Function(Memorial) onTap;

  const MemorialGrid({
    super.key,
    required this.memorials,
    required this.onTap,
  });

  ImageProvider _imageOf(Memorial m) {
    if (m.profilePhotoUrl != null && m.profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(m.profilePhotoUrl!);
    }
    return const AssetImage('assets/images/CreaPerfil.png');
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GridView.builder(
      itemCount: memorials.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) {
        final m = memorials[i];
        return InkWell(
          onTap: () => onTap(m),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(
                    image: _imageOf(m),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                m.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
