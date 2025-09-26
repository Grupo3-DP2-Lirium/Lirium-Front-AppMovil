import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/large_width_button.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/memorial_data/questions.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/select_category_questions.dart';

class SelectQuestions extends StatefulWidget {
  const SelectQuestions({super.key});

  @override
  State<SelectQuestions> createState() => _SelectQuestionsState();
}

class _SelectQuestionsState extends State<SelectQuestions> {
  int? _selectedCategoryIndex;

  void _selectCategory(int index, dynamic category) {
    setState(() => _selectedCategoryIndex = index);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectCategoryQuestions(category: category),
        ),
      );
    });
  }

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
              "Selecciona una categoría de preguntas",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: questionsCategories.length,
                itemBuilder: (context, index) {
                  final category = questionsCategories[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: LargeWidthButton(
                      label: category.name,
                      backgroundColor: _selectedCategoryIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                      onPressed: () => _selectCategory(index, category),
                    ),
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