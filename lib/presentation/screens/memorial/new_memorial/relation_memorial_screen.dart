import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'information_memorial_screen.dart';

class NewMemorialRelationScreen extends StatefulWidget {
  const NewMemorialRelationScreen({super.key});

  @override
  State<NewMemorialRelationScreen> createState() =>
      _NewMemorialRelationScreenState();
}

class _NewMemorialRelationScreenState extends State<NewMemorialRelationScreen> {
  // Lista de opciones (ícono + texto)
  final List<Map<String, dynamic>> options = const [
    {'icon': Icons.family_restroom, 'label': "Familia"},
    {'icon': Icons.group, 'label': "Amigo"},
    {'icon': Icons.pets, 'label': "Mascota"},
    {'icon': Icons.favorite, 'label': "Pareja"},
    {'icon': Icons.attachment, 'label': "Otro"},
  ];

  String? _selectedRelation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // <--- importante
          children: [
            // Parte superior: título, subtítulo y botones de selección
            Column(
              children: [
                const AppTitle(
                  title: "¿A quién le crearás un memorial?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Selecciona una relación",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: options.map((option) {
                    final isSelected = _selectedRelation == option['label'];
                    return RectangleButton(
                      icon: option['icon'],
                      label: option['label'],
                      size: 120,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedRelation = option['label'];
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),

            // Botones abajo con padding para separarlos del fondo
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: "Regresar",
                      textColor: AppColors.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: "Siguiente",
                      onPressed: _selectedRelation == null
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InformationMemorialScreen(
                              relation: _selectedRelation!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}