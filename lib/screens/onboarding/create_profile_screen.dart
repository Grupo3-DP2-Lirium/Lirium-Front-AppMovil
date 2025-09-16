import 'package:flutter/material.dart';
import '../profile/create_profile_form_screen.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Title
              const Text(
                'Crea un perfil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Text(
                'Personaliza tu experiencia\ny comienza a guardar recuerdos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 48),
              // Illustration placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              // Navigation buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Atrás',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateProfileFormScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Siguiente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
