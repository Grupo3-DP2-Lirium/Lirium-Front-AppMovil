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
          Expanded(
            child: SecondaryButton(
              text: backText!,
              onPressed: onBack,
              isFullWidth: false,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: PrimaryButton(
            text: nextText,
            onPressed: onNext,
            isFullWidth: true,
            height: 56,
          ),
        ),
      ],
    );
  }
}
