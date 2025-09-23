import 'package:flutter/material.dart';

class OnboardingLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const OnboardingLayout({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }
}
