import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'share_screen.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      child: Column(
        children: [
          const Spacer(),
          // Title
          const AppTitle(title: 'Crea un perfil', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Subtitle
          const AppSubtitle(
            subtitle:
                'Comienza el legado de tu ser\nquerido con fotos, videos y\nrecuerdos especiales',
          ),
          const SizedBox(height: 48),
          // Create profile illustration
          const AppIllustration(imagePath: 'assets/images/CreaPerfil.png'),
          const Spacer(),
          // Navigation buttons
          NavigationRow(
            onBack: () => Navigator.pop(context),
            onNext: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShareScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
