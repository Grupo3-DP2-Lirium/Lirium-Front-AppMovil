import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'create_profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      child: Column(
        children: [
          const Spacer(),
          // Logo/Title
          const AppTitle(
            title: 'Remory',
            fontSize: 32,
            color: Color(0xFF6366F1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Subtitle
          const AppSubtitle(
            subtitle:
                'un espacio íntimo para construir y\npreservar el legado\nde quienes amas',
          ),
          const SizedBox(height: 48),
          // Family illustration
          const AppIllustration(imagePath: 'assets/images/Remory.png'),
          const Spacer(),
          // Start button
          PrimaryButton(
            text: 'Siguiente',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
