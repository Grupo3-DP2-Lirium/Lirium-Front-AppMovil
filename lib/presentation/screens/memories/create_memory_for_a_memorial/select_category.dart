import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/memorial_data/questions.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/select_questions.dart';

class SelectCategory extends StatefulWidget {
  final String memorialId;
  
  const SelectCategory({super.key, required this.memorialId});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  int? _selectedCategoryIndex;

  // Iconos para cada categoría
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toUpperCase()) {
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

  void _selectCategory(int index, dynamic category) {
    setState(() => _selectedCategoryIndex = index);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectQuestions(
            category: category,
            memorialId: widget.memorialId,
          ),
        ),
      );
    });
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Título principal
              Text(
                "Selecciona una categoría",
                style: AppColors.h3.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Subtítulo
              Text(
                "Elige el tipo de relación para ver preguntas personalizadas",
                style: AppColors.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),

              // Lista de categorías
              Expanded(
                child: ListView.builder(
                  itemCount: questionsCategories.length,
                  itemBuilder: (context, index) {
                    final category = questionsCategories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectCategory(index, category),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : AppColors.inactive,
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                // Icono de categoría
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.2) 
                                        : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category.name),
                                    color: isSelected 
                                        ? Colors.white 
                                        : AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Nombre de la categoría
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: AppColors.h5.copyWith(
                                      color: isSelected 
                                          ? Colors.white 
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                
                                // Flecha
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppColors.textSecondary,
                                  size: 18,
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
      ),
    );
  }
}