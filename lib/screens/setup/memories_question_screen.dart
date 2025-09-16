import 'package:flutter/material.dart';
import 'collaboration_question_screen.dart';

class MemoriesQuestionScreen extends StatefulWidget {
  const MemoriesQuestionScreen({super.key});

  @override
  State<MemoriesQuestionScreen> createState() => _MemoriesQuestionScreenState();
}

class _MemoriesQuestionScreenState extends State<MemoriesQuestionScreen> {
  String? selectedOption;

  final List<String> options = [
    'Familia',
    'Amigos',
    'Pareja',
    'Mascotas',
    'Yo mismo/a',
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
                '¿De quién te gustaría\nguardar recuerdos?',
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
                    final isSelected = selectedOption == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = option;
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
                              Text(
                                option,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CollaborationQuestionScreen(),
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
