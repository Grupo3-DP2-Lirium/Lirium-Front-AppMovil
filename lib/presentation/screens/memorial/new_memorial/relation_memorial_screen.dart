import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'information_memorial_screen.dart';

class NewMemorialRelationScreen extends StatelessWidget {
  const NewMemorialRelationScreen({super.key});

  // Lista de opciones (ícono + texto)
  final List<Map<String, dynamic>> options = const [
    {'icon': Icons.family_restroom, 'label': "Familia"},
    {'icon': Icons.group, 'label': "Amigo"},
    {'icon': Icons.pets, 'label': "Mascota"},
    {'icon': Icons.favorite, 'label': "Pareja"},
    {'icon': Icons.attachment, 'label': "Otro"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 50), // más pegado al subtítulo

            // Botones dinámicos
            Wrap(
              spacing: 24, // espacio horizontal entre botones
              runSpacing: 24, // espacio vertical entre filas
              alignment: WrapAlignment.center,
              children: options.map((option) {
                return RectangleButton(
                  icon: option['icon'],
                  label: option['label'],
                  size: 120,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InformationMemorialScreen(
                          relation: option['label'] // send relation type
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
