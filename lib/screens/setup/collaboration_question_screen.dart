import 'package:flutter/material.dart';
import '../main/main_navigation_screen.dart';

class CollaborationQuestionScreen extends StatefulWidget {
  const CollaborationQuestionScreen({super.key});

  @override
  State<CollaborationQuestionScreen> createState() =>
      _CollaborationQuestionScreenState();
}

class _CollaborationQuestionScreenState
    extends State<CollaborationQuestionScreen> {
  String? selectedOption;

  final List<Map<String, String>> options = [
    {
      'title': 'Sí, quiero que colaboren',
      'subtitle': 'Invitar familiares para crear recuerdos juntos',
    },
    {
      'title': 'No, solo yo por ahora',
      'subtitle': 'Puedo invitar a otros más tarde',
    },
    {'title': 'No estoy seguro/a', 'subtitle': 'Decidir más adelante'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title
              const Text(
                '¿Te gustaría que otros\nfamiliares colaboren?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedOption == option['title'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = option['title'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : Colors.grey[50],
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['title']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? const Color(0xFF6366F1)
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option['subtitle']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedOption != null
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MainNavigationScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
