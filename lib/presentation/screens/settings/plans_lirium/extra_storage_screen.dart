import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class ExtraStorageScreen extends StatefulWidget {
  const ExtraStorageScreen({super.key});

  @override
  State<ExtraStorageScreen> createState() => _ExtraStorageScreenState();
}

class _ExtraStorageScreenState extends State<ExtraStorageScreen> {
  String? selectedOption;

  final List<Map<String, dynamic>> extraOptions = [
    {
      "title": "10 GB extra",
      "description": "Ideal para documentos y fotos",
      "value": "10GB",
      "color": AppColors.primary.withOpacity(0.1),
    },
    {
      "title": "50 GB extra",
      "description": "Perfecto para videos y proyectos grandes",
      "value": "50GB",
      "color": AppColors.primary.withOpacity(0.15),
    },
    {
      "title": "100 GB extra",
      "description": "Para usuarios avanzados que necesitan mucho espacio",
      "value": "100GB",
      "color": AppColors.primary.withOpacity(0.2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Agregar espacio extra",
        onBack: () => Navigator.pop(context),
        appBarHeight: appBarHeight,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              "Selecciona la cantidad de espacio extra que deseas agregar a tu plan:",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: extraOptions.length,
                itemBuilder: (context, index) {
                  final option = extraOptions[index];
                  final isSelected = selectedOption == option['value'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = option['value'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(20),
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [AppColors.primary.withOpacity(0.3), option['color']]
                              : [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.secondary.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            size: 28,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary.withOpacity(0.5),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  option['title'],
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  option['description'],
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: "Agregar espacio",
              color: AppColors.primary2,
              onPressed: selectedOption == null
                  ? null
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Se agregó $selectedOption a tu plan ✅"),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
