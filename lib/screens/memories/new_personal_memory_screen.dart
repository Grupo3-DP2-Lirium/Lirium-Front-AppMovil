import 'package:flutter/material.dart';

class NewPersonalMemoryScreen extends StatefulWidget {
  const NewPersonalMemoryScreen({super.key});

  @override
  State<NewPersonalMemoryScreen> createState() => _NewPersonalMemoryScreenState();
}

class _NewPersonalMemoryScreenState extends State<NewPersonalMemoryScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
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
              onPressed: () {
                // TODO: guardar memoria
                Navigator.pop(context);
              },
              icon: Icon(Icons.check_circle, color: cs.primary, size: 28),
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
