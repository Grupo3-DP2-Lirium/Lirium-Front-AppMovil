import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/question_category.dart';
import 'package:flutter_frontend/presentation/components/buttons/large_width_button.dart';

class SelectCategoryQuestions extends StatefulWidget {
  final QuestionCategory category;
  
  const SelectCategoryQuestions({
    super.key,
    required this.category,
  });

  @override
  State<SelectCategoryQuestions> createState() => _SelectCategoryQuestionsState();
}

class _SelectCategoryQuestionsState extends State<SelectCategoryQuestions> {
  String? selectedQuestion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Preguntas",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.category.name,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Selecciona una pregunta para responder",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            Expanded(
              child: ListView.builder(
                itemCount: widget.category.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.category.questions[index];
                  final isSelected = selectedQuestion == question;
                  
                  return LargeWidthButton(
                    label: question,
                    backgroundColor: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey.shade300,
                    onPressed: () {
                      setState(() {
                        selectedQuestion = question;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pregunta seleccionada: $question'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}