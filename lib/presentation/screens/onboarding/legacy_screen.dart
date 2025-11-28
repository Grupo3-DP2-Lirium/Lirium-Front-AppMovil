import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/components.dart';
import '../auth/login_screen.dart';

class LegacyScreen extends StatelessWidget {
  const LegacyScreen({super.key});

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    print('✅ Onboarding marcado como completado');
  }

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
          const AppIllustration(
            imagePath: 'assets/images/ContruyeLegado.png',
            height: 200,
          ),
          const Spacer(),
          // Navigation buttons
          NavigationRow(
            nextText: 'Continuar',
            onBack: () => Navigator.pop(context),
            onNext: () async {
              await _markOnboardingComplete();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
