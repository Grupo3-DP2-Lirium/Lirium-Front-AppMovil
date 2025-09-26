import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/memory_saved_screen.dart';

/// Pantalla para responder una pregunta seleccionada.
/// Soporta tres modos: grabar audio, grabar video y escribir texto (placeholder para grabaciones).
class AnswerQuestionScreen extends StatefulWidget {
  final String categoryName;
  final String question;
  final String? memorialId; // opcional para futura integración API

  const AnswerQuestionScreen({super.key, required this.categoryName, required this.question, this.memorialId});

  @override
  State<AnswerQuestionScreen> createState() => _AnswerQuestionScreenState();
}

enum AnswerMode { audio, video, text }

class _AnswerQuestionScreenState extends State<AnswerQuestionScreen> {
  AnswerMode? _mode; // modo seleccionado
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    if (_mode == AnswerMode.text && _controller.text.trim().isEmpty) return; // no permitir vacío
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600)); // simulación
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MemorySavedScreen(
          categoryName: widget.categoryName,
          question: widget.question,
          memorialId: widget.memorialId,
        ),
      ),
    );
  }

  Color get _primary => const Color(0xFF6366F1);

  Widget _buildModeSelector({required String label, required IconData icon, required AnswerMode mode}) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _primary : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : Colors.black87),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                letterSpacing: .5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_mode == null) {
      return const Center(
        child: Text(
          'Selecciona un modo para responder',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_mode == AnswerMode.text) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu respuesta ...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      );
    }
    // Placeholder para audio/video
    final isAudio = _mode == AnswerMode.audio;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isAudio ? Icons.mic : Icons.videocam, size: 80, color: _primary),
          const SizedBox(height: 16),
            Text(
              isAudio ? 'Grabación de audio (pendiente de implementar)' : 'Grabación de video (pendiente de implementar)',
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAudio ? 'Simulando guardado de audio' : 'Simulando guardado de video')),
              );
              _saveMemory();
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Tarjeta de la pregunta
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E6EC)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildModeSelector(label: 'Grabar audio', icon: Icons.mic, mode: AnswerMode.audio),
                      _buildModeSelector(label: 'Grabar video', icon: Icons.videocam_outlined, mode: AnswerMode.video),
                      _buildModeSelector(label: 'Escribir respuesta', icon: Icons.edit_outlined, mode: AnswerMode.text),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _mode == AnswerMode.text
          ? FloatingActionButton(
              backgroundColor: (_controller.text.trim().isEmpty || _saving) ? Colors.grey : _primary,
              onPressed: (_controller.text.trim().isEmpty || _saving) ? null : _saveMemory,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }
}
