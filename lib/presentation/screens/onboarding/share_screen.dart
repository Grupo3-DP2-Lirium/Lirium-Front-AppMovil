import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'legacy_screen.dart';
import '../settings/plans_lirium/get_premium_screen.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      // Usamos LayoutBuilder para adaptar el contenido si la pantalla es pequeña
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20), // Spacer superior simulado
                    // Title
                    const AppTitle(title: 'Compártelo', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    // Subtitle
                    const AppSubtitle(
                      subtitle:
                          'Conecta con familiares y amigos\npara crear recuerdos juntos',
                    ),
                    const SizedBox(height: 32),
                    
                    // Opciones
                    _buildOptionCard(
                      index: 0,
                      title: 'Sí, quiero que colaboren',
                      subtitle: 'Invitar familiares para crear recuerdos juntos',
                    ),
                    const SizedBox(height: 12),
                    _buildOptionCard(
                      index: 1,
                      title: 'No, solo yo por ahora',
                      subtitle: 'Puedo invitar a otros más tarde',
                    ),
                    const SizedBox(height: 12),
                    _buildOptionCard(
                      index: 2,
                      title: 'No estoy seguro/a',
                      subtitle: 'Decidir más adelante',
                    ),
                    
                    const Spacer(), 
                    const SizedBox(height: 24),
                    
                    // Navigation buttons
                    NavigationRow(
                      onBack: () => Navigator.pop(context),
                      nextText: 'Continuar',
                      onNext: () {
                        print("🔵 SHARE: Continuar presionado. Opción: $_selectedOption");
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GetPremiumScreen(
                                onboardingSelection: _selectedOption,
                              ),
                            ),
                          );
                        } catch (e) {
                          print("❌ SHARE: Error navegando a Premium: $e");
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LegacyScreen()),
                        );
                      },
                      child: const Text(
                        'Omitir',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedOption == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedOption,
              onChanged: (val) => setState(() => _selectedOption = val!),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
