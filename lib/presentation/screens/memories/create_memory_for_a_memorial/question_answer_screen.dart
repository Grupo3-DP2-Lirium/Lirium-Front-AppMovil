import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/answer_button.dart';

/// Pantalla para responder una pregunta específica con múltiples opciones
class QuestionAnswerScreen extends StatelessWidget {
  final String question;

  const QuestionAnswerScreen({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Responder'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Pregunta en recuadro
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botones de respuesta
              AnswerButton(
                icon: Icons.mic,
                text: 'GRABAR AUDIO',
                color: const Color(0xFF9CA3AF),
                onPressed: () => _recordAudio(context),
              ),
              
              const SizedBox(height: 16),
              
              AnswerButton(
                icon: Icons.videocam,
                text: 'GRABAR VIDEO',
                color: const Color(0xFF6366F1),
                onPressed: () => _recordVideo(context),
              ),
              
              const SizedBox(height: 16),
              
              AnswerButton(
                icon: Icons.edit,
                text: 'ESCRIBIR RESPUESTA',
                color: const Color(0xFFE5E7EB),
                textColor: const Color(0xFF9CA3AF),
                onPressed: null, // Deshabilitado
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _recordAudio(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de audio próximamente')),
    );
  }

  void _recordVideo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de video próximamente')),
    );
  }
}