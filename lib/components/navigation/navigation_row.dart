import 'package:flutter/material.dart';
import '../buttons/secondary_button.dart';
import '../buttons/primary_button.dart';

class NavigationRow extends StatelessWidget {
  final String? backText;
  final String nextText;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool showBackButton;

  const NavigationRow({
    super.key,
    this.backText = 'Atrás',
    this.nextText = 'Siguiente',
    this.onBack,
    this.onNext,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          SecondaryButton(text: backText!, onPressed: onBack),
          const Spacer(),
        ],
        SizedBox(
          width: 120,
          child: PrimaryButton(
            text: nextText,
            onPressed: onNext,
            isFullWidth: false,
            height: 56,
          ),
        ),
      ],
    );
  }
}
