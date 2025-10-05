import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memories/memories_grid_screen.dart';

class MemoryCreatedScreen extends StatelessWidget {
  final Memory memory;

  const MemoryCreatedScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              "Tu memoria ha sido actualizada correctamente",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Icon or image
            Icon(
              Icons.auto_stories_rounded,
              size: screenWidth * 0.3,
              color: Colors.deepPurpleAccent,
            ),

            SizedBox(height: screenHeight * 0.08),

            // Continue button
            PrimaryButton(
              text: "Continuar",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MemoriesGridScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}