import 'package:flutter/material.dart';

class AppIllustration extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final double height;
  final BoxFit fit;
  final Color? iconColor;
  final double? iconSize;

  const AppIllustration({
    super.key,
    this.imagePath,
    this.icon,
    this.height = 250,
    this.fit = BoxFit.contain,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: imagePath == null ? Colors.grey[100] : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(imagePath!, fit: fit),
              )
            : Center(
                child: Icon(
                  icon ?? Icons.image,
                  size: iconSize ?? 80,
                  color: iconColor ?? const Color(0xFF6366F1),
                ),
              ),
      ),
    );
  }
}
