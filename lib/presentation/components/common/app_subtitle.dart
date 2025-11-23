import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSubtitle extends StatelessWidget {
  final String subtitle;
  final TextAlign textAlign;
  final Color? color;

  const AppSubtitle({
    super.key,
    required this.subtitle,
    this.textAlign = TextAlign.center,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}
