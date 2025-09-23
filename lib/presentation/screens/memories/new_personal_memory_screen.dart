import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';

// TODO: reemplaza por cómo guardas/obtienes tu JWT
String get currentJwt => "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NTAzMzM5LCJleHAiOjE3NTg1ODk3Mzl9.BA7jDWvCHZObHbTcTjtfNwcIgqa-EbFXagjUYLZfvQT3PG61pZESamkUzTzgDtFr"; // solo el token, sin 'Bearer '

class NewPersonalMemoryScreen extends StatefulWidget {
  const NewPersonalMemoryScreen({super.key});

  @override
  State<NewPersonalMemoryScreen> createState() => _NewPersonalMemoryScreenState();
}

class _NewPersonalMemoryScreenState extends State<NewPersonalMemoryScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final desc  = _bodyCtrl.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y contenido')),
      );
      return;
    }

    final memoryJson = {
      "memorialId": "0EAE29A7-C601-4BB2-931D-3ADBB3E04E55", // TODO: origen real
      "title": title,
      "description": desc,
      "photoDate": DateTime.now().toIso8601String().split('T').first, // o tu fecha real
      "location": "Lima, Perú",
      "visible": true,
      "tags": <String>[],
      "type": "SPONTANEOUS",
      "associatedQuestion": null,
      "questionId": null,
      "answerId": null
    };

    setState(() => _saving = true);
    try {
      final service = MemoryService();
      // Si no hay archivos: files: null. Si hay, pasa una lista de File.
      final result = await service.createPersonalMemory(
        token: currentJwt,
        memoryJson: memoryJson,
        files: null, // o [File('/ruta/a/mi_imagen.png')]
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memoria guardada con éxito')),
      );
      Navigator.pop(context, result); // puedes devolver el JSON creado
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.check_circle, color: cs.primary, size: 28),
              tooltip: 'Guardar',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Editor
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Empezar a escribir...',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            // Barra de atajos sobre el teclado
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE7E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Cámara',
                        icon: const Icon(Icons.photo_camera_outlined),
                        onPressed: () {/* TODO: abrir cámara */},
                      ),
                      IconButton(
                        tooltip: 'Audio',
                        icon: const Icon(Icons.mic_none_outlined),
                        onPressed: () {/* TODO: grabar audio */},
                      ),
                      IconButton(
                        tooltip: 'Galería',
                        icon: const Icon(Icons.image_outlined),
                        onPressed: () {/* TODO: abrir galería */},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
