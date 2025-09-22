import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/buttons/rectangle_button.dart';
import 'package:flutter_frontend/components/common/app_title.dart';

class NewMemorialRelationScreen extends StatelessWidget {
  const NewMemorialRelationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Arriba
          crossAxisAlignment: CrossAxisAlignment.center, // Centrado horizontal
          children: [
            // Título principal
            const AppTitle(
              title: "¿A quién le crearás un memorial?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtítulo
            const Text(
              "Selecciona una relación",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Primera fila
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RectangleButton(
                  icon: Icons.family_restroom,
                  label: "Familia",
                  size: 120,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                RectangleButton(
                  icon: Icons.group,
                  label: "Amigos",
                  size: 120,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Segunda fila
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RectangleButton(
                  icon: Icons.pets,
                  label: "Mascota",
                  size: 120,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                RectangleButton(
                  icon: Icons.favorite,
                  label: "Pareja",
                  size: 120,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Último botón centrado
            RectangleButton(
              icon: Icons.attachment,
              label: "Otro",
              size: 120,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
