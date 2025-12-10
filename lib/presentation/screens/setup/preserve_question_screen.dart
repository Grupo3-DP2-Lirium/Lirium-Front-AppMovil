import 'package:flutter/material.dart';
import '../../components/components.dart';
import 'memories_question_screen.dart';

class PreserveQuestionScreen extends StatefulWidget {
  const PreserveQuestionScreen({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<PreserveQuestionScreen> createState() => _PreserveQuestionScreenState();
}

class _PreserveQuestionScreenState extends State<PreserveQuestionScreen> {
  String? selectedOption;

  final List<Map<String, dynamic>> options = [
    {'title': 'Mis recuerdos personales', 'icon': Icons.person_outline},
    {'title': 'Memorias de algún familiar', 'icon': Icons.family_restroom},
    {'title': 'Eventos especiales', 'icon': Icons.event},
    {'title': 'Fotos y videos', 'icon': Icons.photo_library},
  ];

  @override
  Widget build(BuildContext context) {
    return QuestionLayout(
      title: '¿Qué quieres preservar\nprincipalmente?',
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
                    builder: (context) => MemoriesQuestionScreen(userEmail: widget.userEmail),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
