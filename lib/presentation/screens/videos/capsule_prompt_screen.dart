import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_creative_screen.dart';

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
  final _promptCtrl = TextEditingController();

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nueva Cápsula'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AppTitle(title: 'Paso 2: Tu idea'),
              const SizedBox(height: 12),
              Text(
                'Memorial: ${widget.memorialName}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Prompt libre',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _promptCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ej.: Cumpleaños 80 de Lupi, Navidad 2023 en casa…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa tu idea' : null,
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Continuar',
                icon: Icons.arrow_forward,
                isFullWidth: true,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CapsuleCreativeScreen(
                        memorialId: widget.memorialId,
                        memorialName: widget.memorialName,
                        userPrompt: _promptCtrl.text.trim(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Usaremos tu prompt para elegir automáticamente los recuerdos más relevantes.',
                        style: TextStyle(color: Colors.grey[800], fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
