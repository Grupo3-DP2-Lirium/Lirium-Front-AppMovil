import 'package:flutter/material.dart';

class QuestionLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomButton;
  final EdgeInsets? padding;

  const QuestionLayout({
    super.key,
    required this.title,
    required this.child,
    this.bottomButton,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),
              // Content
              Expanded(child: child),
              // Bottom button
              if (bottomButton != null) ...[
                bottomButton!,
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
