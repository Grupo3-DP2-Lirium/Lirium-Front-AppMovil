import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import '../../components/components.dart';
import '../auth/login_screen.dart';

class LegacyScreen extends StatelessWidget {
  const LegacyScreen({super.key});

  Future<void> _markOnboardingComplete() async {
    try {
      await StorageService.markOnboardingCompleted();
      print('✅ LEGACY: Onboarding marcado como completado (SharedPreferences)');
    } catch (e) {
      print('❌ LEGACY: Error guardando onboarding: $e');
    }
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
              print('🔵 LEGACY: Botón Continuar presionado');
              await _markOnboardingComplete();

              // Esperar un momento para asegurar que se guardó
              await Future.delayed(const Duration(milliseconds: 500));

              if (context.mounted) {
                print('🔵 LEGACY: Navegando al LoginScreen');
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
