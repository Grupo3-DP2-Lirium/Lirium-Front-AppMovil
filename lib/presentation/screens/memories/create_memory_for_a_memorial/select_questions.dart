import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/question_category.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'answer_question_screen.dart';

class SelectQuestions extends StatefulWidget {
  final QuestionCategory category;
  final String memorialId;
  
  const SelectQuestions({
    super.key,
    required this.category,
    required this.memorialId,
  });

  @override
  State<SelectQuestions> createState() => _SelectQuestionsState();
}

class _SelectQuestionsState extends State<SelectQuestions> {
  String? selectedQuestion;

  // Icono según categoría
  IconData _getCategoryIcon() {
    switch (widget.category.name.toUpperCase()) {
      case 'FAMILIA':
        return Icons.family_restroom;
      case 'AMIGOS':
        return Icons.people;
      case 'PAREJA':
        return Icons.favorite;
      case 'MASCOTA':
        return Icons.pets;
      case 'OTRO':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Preguntas",
          style: AppColors.h5.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con categoría
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
              ),
              child: Column(
                children: [
                  // Icono de categoría
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Nombre de la categoría
                  Text(
                    widget.category.name,
                    style: AppColors.h3.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtítulo
                  Text(
                    "Selecciona una pregunta para responder",
                    style: AppColors.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Lista de preguntas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: widget.category.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.category.questions[index];
                  final isSelected = selectedQuestion == question;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() { selectedQuestion = question; });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnswerQuestionScreen(
                                categoryName: widget.category.name,
                                question: question,
                                memorialId: widget.memorialId,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.inactive,
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                    ? AppColors.primary.withOpacity(0.25)
                                    : Colors.black.withOpacity(0.03),
                                blurRadius: isSelected ? 10 : 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Número de pregunta
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.white.withOpacity(0.2) 
                                      : AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected 
                                          ? Colors.white 
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 14),
                              
                              // Texto de la pregunta
                              Expanded(
                                child: Text(
                                  question,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected 
                                        ? Colors.white 
                                        : AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Icono de flecha
                              Icon(
                                Icons.arrow_forward_ios,
                                color: isSelected 
                                    ? Colors.white 
                                    : AppColors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
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