import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_create_request.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/enums/memory_origin_type.dart';
import 'package:flutter_frontend/providers/memories_by_memorial_provider.dart';
import '../../../../providers/memory_provider.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/common/app_pop_up.dart';
import 'package:provider/provider.dart';

/// Pantalla para escribir una carta personal
class WriteLetterScreen extends StatefulWidget {
  final String memorialId;
  final String memorialName;

  const WriteLetterScreen({
    super.key,
    required this.memorialId,
    required this.memorialName
  });

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final TextEditingController _letterController = TextEditingController();
  final MemoryService _memoryService = MemoryService();

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  Future<void> _saveLetter() async {
    if (_letterController.text.trim().isEmpty) {
      _showError('Por favor escribe tu mensaje');
      return;
    }

    // Pop-up de Guardando
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    try {
      final request = MemoryCreateRequest(
        memorialId: widget.memorialId,
        type: MemoryOriginType.spontaneous,
        title: 'Carta personal',
        description: _letterController.text.trim(),
        photoDate: DateTime.now(),
      );

      final createdMemoryResponse = await _memoryService.createMemory(
        request: request,
        files: null,
      );

      final createdMemory = createdMemoryResponse.toEntity();

      Provider.of<MemoryProvider>(context, listen: false)
          .agregarMemoria(createdMemory);

      final memoriesProvider = context.read<MemoriesByMemorialProvider>();
      memoriesProvider.addMemory(createdMemory);

      Navigator.pop(context); // Cerrar popup de guardando

      // Mostrar popup de éxito
      await appPopupButtonDefault(
        context: context,
        title: "Tu recuerdo ha sido creado",
        message: "Gracias por compartir un momento más de tu historia",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context); // Cerrar popup
              Navigator.pop(context, createdMemory); // Regresar con el memory creado
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar popup de guardando si hay error
      _showError('Error al guardar la carta: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Escribir Carta'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Text(
                '¿Qué te gustaría decirle a ${widget.memorialName}?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // Campo de texto
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _letterController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje aquí...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón PrimaryButton debajo
              PrimaryButton(
                text: 'Guardar',
                onPressed: _saveLetter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}