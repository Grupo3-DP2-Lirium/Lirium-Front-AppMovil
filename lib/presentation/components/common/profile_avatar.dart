import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool showCameraIcon;
  final IconData? placeholderIcon;

  const ProfileAvatar({
    super.key,
    this.radius = 30,
    this.imageUrl,
    this.onTap,
    this.showCameraIcon = false,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Icon(
                    placeholderIcon ?? Icons.person,
                    color: Colors.grey,
                    size: radius * 0.8,
                  )
                : null,
          ),
          if (showCameraIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.6,
                height: radius * 0.6,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.3,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
