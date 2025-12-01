import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_details_state.dart';

class MemorialHeader extends StatelessWidget {
  final MemorialDetailsState detailsState;
  final String? coverUrl;
  final bool isHeaderCollapsed;
  final VoidCallback onBack;

  const MemorialHeader({
    super.key,
    required this.detailsState,
    required this.coverUrl,
    required this.isHeaderCollapsed,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHeaderCollapsed ? Colors.transparent : Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isHeaderCollapsed ? AppColors.textPrimary : Colors.white,
          ),
          onPressed: onBack,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: isHeaderCollapsed
            ? Text(
          detailsState.name ?? '',
          style: AppColors.h6.copyWith(fontSize: 16),
        )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            Image(
              image: _getCoverImage(),
              fit: BoxFit.cover,
            ),

            // Gradient overlay mejorado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.0, 0.6, 0.7],
                ),
              ),
            ),

            // Profile info
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Avatar con sombra
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: _getAvatarImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    detailsState.name ?? 'Cargando...',
                    style: AppColors.h3.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 6),

                  // Relation
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      detailsState.relation,
                      style: AppColors.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Description
                  if (detailsState.description != null && detailsState.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
                      child: Text(
                        detailsState.description!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppColors.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getAvatarImage() {
    final avatarUrl = detailsState.profilePhotoUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image') || avatarUrl.length > 500) {
        try {
          final base64String = avatarUrl.contains(',') ? avatarUrl.split(',').last : avatarUrl;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          return const AssetImage('assets/images/CreaPerfil.png');
        }
      } else {
        return NetworkImage(avatarUrl);
      }
    }
    return const AssetImage('assets/images/CreaPerfil.png');
  }

  ImageProvider _getCoverImage() {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return const NetworkImage('https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800');
    }
    if (coverUrl!.startsWith('data:image')) {
      final base64Str = coverUrl!.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }
    return NetworkImage(coverUrl!);
  }
}