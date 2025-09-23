import 'package:flutter/material.dart';
import '../../components/components.dart';
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
    return QuestionLayout(
      title: '¿Te gustaría que otros\nfamiliares colaboren?',
      child: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return OptionCard(
            title: option['title']!,
            subtitle: option['subtitle'],
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
