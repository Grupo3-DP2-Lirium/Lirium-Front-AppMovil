import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../auth/login_screen.dart';

class LegacyScreen extends StatelessWidget {
  const LegacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      child: Column(
        children: [
          const Spacer(),
          // Title
          const AppTitle(
            title: 'Construye tu legado',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Subtitle
          const AppSubtitle(
            subtitle:
                'Preserva momentos especiales\npara las futuras generaciones',
          ),
          const SizedBox(height: 48),
          // Legacy illustration
          const AppIllustration(icon: Icons.family_restroom, height: 200),
          const Spacer(),
          // Navigation buttons
          NavigationRow(
            nextText: 'Continuar',
            onBack: () => Navigator.pop(context),
            onNext: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
