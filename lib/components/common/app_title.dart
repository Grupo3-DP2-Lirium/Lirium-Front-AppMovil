import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const AppTitle({
    super.key,
    required this.title,
    this.fontSize = 28,
    this.color,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.black87,
      ),
    );
  }
}

class AppSubtitle extends StatelessWidget {
  final String subtitle;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;
  final double height;

  const AppSubtitle({
    super.key,
    required this.subtitle,
    this.fontSize = 16,
    this.color,
    this.textAlign = TextAlign.center,
    this.height = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? Colors.grey,
        height: height,
      ),
    );
  }
}
