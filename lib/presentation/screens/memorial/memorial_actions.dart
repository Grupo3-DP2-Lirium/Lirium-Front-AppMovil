import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';

class MemorialActions {
  final MemorialService _memorialService = MemorialService();

  /// Eliminar un memorial
  Future<void> deleteMemorial(BuildContext context, String memorialId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este memorial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false)) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _memorialService.deleteMemorial(memorialId);

      // Actualizar provider
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      provider.eliminarMemorial(memorialId);

      Navigator.pop(context); // Cerrar loading

      // Mostrar popup de éxito
      await appPopupButtonDefault(
        context: context,
        title: "Memorial eliminado",
        message: "El memorial ha sido eliminado correctamente",
        buttons: [
          AppPopupButton(
            text: "Continuar",
            onPressed: () {
              Navigator.pop(context); // cierra el popup
              Navigator.pop(context); // retrocede a la pantalla anterior
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  /// Compartir el memorial
  Future<void> shareMemorial(BuildContext context, String memorialId) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generar el link de compartir usando el servicio
      final result = await _memorialService.generateShareLink(memorialId);
      
      Navigator.pop(context); // Cerrar loading
      Navigator.pop(context); // Cerrar modal de opciones

      // Extraer el link del resultado
      final shareLink = result['url'] ?? '';
      print('DEBUG: Share link generated: $shareLink');
      if (shareLink.isEmpty) {
        throw Exception('No se pudo generar el link de compartir');
      }

      // Mostrar el link en un dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Compartir Memorial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Link para compartir:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  shareLink,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Copiar al portapapeles
                await Clipboard.setData(ClipboardData(text: shareLink));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copiado al portapapeles'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Copiar Link'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
