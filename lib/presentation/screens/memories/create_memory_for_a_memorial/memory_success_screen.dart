import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:flutter_frontend/presentation/screens/main/main_navigation_screen.dart';
import 'create_memory_select_type.dart';

/// Pantalla de confirmación cuando una memoria es guardada exitosamente
class MemorySuccessScreen extends StatelessWidget {
  const MemorySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Mensaje de éxito
              const Text(
                '¡TU MEMORIA HA SIDO GUARDADA!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Icono de casa
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const Spacer(),
              
              // Botones de acción
              Column(
                children: [
                  PrimaryButton(
                    text: 'SEGUIR AÑADIENDO',
                    onPressed: () => _goToAddMore(context),
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'FINALIZAR',
                    onPressed: () => _goToHome(context),
                    textColor: const Color(0xFF6366F1),
                    isOutlined: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToAddMore(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateMemorySelectType(memorialId:"1"),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }
}