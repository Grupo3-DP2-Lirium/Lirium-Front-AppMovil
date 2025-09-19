import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'legacy_screen.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      child: Column(
        children: [
          const Spacer(),
          // Title
          const AppTitle(title: 'Compártelo', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Subtitle
          const AppSubtitle(
            subtitle:
                'Conecta con familiares y amigos\npara crear recuerdos juntos',
          ),
          const SizedBox(height: 48),
          // Share illustration
          const AppIllustration(
            imagePath: 'assets/images/Compartelo.png',
            height: 200,
          ),
          const Spacer(),
          // Navigation buttons
          NavigationRow(
            onBack: () => Navigator.pop(context),
            onNext: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LegacyScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
