import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'create_profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingLayout(
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset( //ícono de Lirium
              'assets/images/img19.jpg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          // Logo/Title
          AppTitle(
            title: 'Lirium',
            fontSize: 32,
            color: theme.primaryColor,
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
