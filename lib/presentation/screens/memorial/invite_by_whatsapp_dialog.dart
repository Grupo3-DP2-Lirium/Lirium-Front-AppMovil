// lib/presentation/screens/memorial/invite_by_whatsapp_dialog.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_frontend/data/services/invite_code_service.dart';

class InviteByWhatsAppDialog extends StatefulWidget {
  final String memorialId;
  final String? memorialName;
  
  const InviteByWhatsAppDialog({
    super.key,
    required this.memorialId,
    required this.memorialName,
  });
  
  @override
  State<InviteByWhatsAppDialog> createState() => _InviteByWhatsAppDialogState();
}

class _InviteByWhatsAppDialogState extends State<InviteByWhatsAppDialog> {
  final InviteCodeService _service = InviteCodeService();
  
  bool _canEdit = false;
  bool _canComment = false;
  bool _isGenerating = false;
  bool _generationComplete = false;
  String? _errorMessage;
  
  Future<void> _generateAndShare() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    
    try {
      // 1. Generar el código
      final response = await _service.createInviteCode(
        memorialId: widget.memorialId,
        canEdit: _canEdit,
        canComment: _canComment,
        maxUses: 1,
      );
      
      // 2. Preparar el mensaje
      final permissions = <String>[];
      if (_canEdit) permissions.add('✏️ Editar contenido');
      if (_canComment) permissions.add('💬 Comentar');
      if (permissions.isEmpty) permissions.add('👁️ Ver contenido');
      
      final permissionsText = permissions.join('\n');
      final memorialName = widget.memorialName ?? "mi memorial";
      final message = '''
🕊️ *Te invito a mi memorial en Lirium*

He creado "${memorialName}", un espacio especial para honrar y preservar recuerdos importantes, y me encantaría que formaras parte de él.

*Tu código de invitación:* `${response.code}`

*Tus permisos:*
$permissionsText

📱 *¿Cómo unirte?*
1. Ingresa sesión a Lirium en tu dispositivo móvil
2. Busca la opción "Memoriales" en la parte inferior
3. Selecciona "Colaboraciones" en la parte inferior
4. Toca "Ingresar código"
5. Ingresa: ${response.code}

⏰ *Válido por 24 horas*
''';

      // 3. Abrir WhatsApp
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        
        // Marcar como completado
        setState(() {
          _generationComplete = true;
          _isGenerating = false;
        });
        
        // Cerrar el diálogo después de un momento
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('No se pudo abrir WhatsApp');
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isGenerating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _generationComplete
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFF25D366), const Color(0xFF128C7E)], // Colores de WhatsApp
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _generationComplete ? Icons.check_circle : Icons.chat_bubble,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _generationComplete
                          ? '¡Invitación enviada!'
                          : 'Invitar por WhatsApp',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!_generationComplete)
                      const SizedBox(height: 8),
                    if (!_generationComplete)
                      Text(
                        'Para "${widget.memorialName}"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: _generationComplete
                    ? _buildSuccessView()
                    : _buildConfigurationView(colorScheme),
              ),
            ],
          ),
        ),
      ),
      actions: _generationComplete ? null : [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF6366F1)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateAndShare,
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send, size: 18),
          label: Text(_isGenerating ? 'Generando...' : 'Compartir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), // Color de WhatsApp
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildConfigurationView(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Explicación
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF25D366).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF128C7E),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Se generará un código automáticamente y se abrirá WhatsApp',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Configura los permisos:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
        
        const SizedBox(height: 12),
        
        // Switches de permisos
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Puede editar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                ),
                subtitle: Text(
                  'Crear y modificar contenido',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                value: _canEdit,
                onChanged: _isGenerating ? null : (value) => setState(() => _canEdit = value),
                activeColor: const Color(0xFF25D366),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              SwitchListTile(
                title: Text(
                  'Puede comentar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                ),
                subtitle: Text(
                  'Agregar comentarios (próximamente)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                value: _canComment,
                onChanged: _isGenerating ? null : (value) => setState(() => _canComment = value),
                activeColor: const Color(0xFF25D366),
              ),
            ],
          ),
        ),
        
        // Mensaje de error
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 60,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¡Listo!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'WhatsApp se abrió con tu invitación.\nSelecciona a quién enviarla.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}