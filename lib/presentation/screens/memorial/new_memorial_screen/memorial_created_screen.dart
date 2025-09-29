import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memorial.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_detail_screen.dart';

class MemorialCreatedScreen extends StatelessWidget {
  final Memorial memorial;

  const MemorialCreatedScreen({super.key, required this.memorial});

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
              "Tu memorial ha sido creado correctamente",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Subtitle with the name
            Text(
              "Comienza a crear la historia de ${memorial.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

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
                  MaterialPageRoute(
                    builder: (_) => MemorialDetailScreen(
                      memorialId: memorial.idMemorial,
                      name: memorial.name,
                      description: memorial.description,
                      coverUrl: memorial.profilePhotoBase64,
                      avatarUrl: memorial.profilePhotoBase64,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
