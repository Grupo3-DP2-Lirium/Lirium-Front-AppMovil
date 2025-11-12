import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_config_screen.dart';

class CapsulePromptScreen extends StatefulWidget {
  final String memorialId;
  final String memorialName;

  const CapsulePromptScreen({
    super.key,
    required this.memorialId,
    required this.memorialName,
  });

  @override
  State<CapsulePromptScreen> createState() => _CapsulePromptScreenState();
}

class _CapsulePromptScreenState extends State<CapsulePromptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Describe tu cápsula'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Memorial seleccionado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cápsula sobre',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            widget.memorialName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                '¿Qué momento quieres revivir?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Describe el momento o evento que quieres capturar. La IA seleccionará automáticamente los mejores recuerdos.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Campo de prompt
              TextFormField(
                controller: _promptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                  'Ej: "Cumpleaños 80 de mamá"\n"Navidad 2023 en casa"\n"Viaje a la playa en verano"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Colors.purple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Describe el momento que quieres capturar';
                  }
                  if (value.length < 5) {
                    return 'La descripción debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Ejemplos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.purple[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ejemplos de prompts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExampleItem('🎂 "Cumpleaños 80 de Lupi"'),
                    _buildExampleItem('🎄 "Navidad 2023"'),
                    _buildExampleItem('🏖️ "Verano en la playa con la familia"'),
                    _buildExampleItem('🎓 "Graduación de universidad"'),
                    _buildExampleItem('❤️ "Aniversario de bodas"'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botón continuar
              PrimaryButton(
                text: 'Continuar',
                icon: Icons.arrow_forward,
                isFullWidth: true,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CapsuleConfigScreen(
                          memorialId: widget.memorialId,
                          memorialName: widget.memorialName,
                          userPrompt: _promptController.text.trim(),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Info adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La IA analizará tus recuerdos y seleccionará automáticamente los más relevantes para crear una cápsula de máximo 60 segundos.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.purple[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.purple[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}