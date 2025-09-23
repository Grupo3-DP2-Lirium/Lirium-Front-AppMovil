import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'collaboration_question_screen.dart';

class MemoriesQuestionScreen extends StatefulWidget {
  const MemoriesQuestionScreen({super.key});

  @override
  State<MemoriesQuestionScreen> createState() => _MemoriesQuestionScreenState();
}

class _MemoriesQuestionScreenState extends State<MemoriesQuestionScreen> {
  String? selectedOption;

  final List<Map<String, dynamic>> options = [
    {'title': 'Familia', 'icon': Icons.family_restroom},
    {'title': 'Amigos', 'icon': Icons.people},
    {'title': 'Pareja', 'icon': Icons.favorite},
    {'title': 'Mascotas', 'icon': Icons.pets},
    {'title': 'Yo mismo/a', 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      title: '¿De quién te gustaría\nguardar recuerdos?',
      child: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return OptionCard(
            title: option['title'],
            icon: option['icon'],
            isSelected: selectedOption == option['title'],
            onTap: () {
              setState(() {
                selectedOption = option['title'];
              });
            },
          );
        },
      ),
      bottomButton: PrimaryButton(
        text: 'Continuar',
        onPressed: selectedOption != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CollaborationQuestionScreen(),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
