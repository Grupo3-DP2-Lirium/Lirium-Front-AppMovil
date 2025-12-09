import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/collaborator_service.dart';
import 'package:flutter_frontend/data/models/collaborator_response.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborative_memorials/generate_invite_code_dialog.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborative_memorials/invite_by_email_dialog.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborative_memorials/invite_by_whatsapp_dialog.dart'; // ✅ NUEVO

class CollaboratorsScreen extends StatefulWidget {
  final String memorialId;
  final String? memorialName; // ✅ AGREGAR esto
  
  const CollaboratorsScreen({
    super.key,
    required this.memorialId,
    required this.memorialName, // ✅ AGREGAR esto
  });
  
  @override
  State<CollaboratorsScreen> createState() => _CollaboratorsScreenState();
}

class _CollaboratorsScreenState extends State<CollaboratorsScreen> {
  final CollaboratorService _service = CollaboratorService();
  
  List<CollaboratorResponse> _collaborators = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }
  
  Future<void> _loadCollaborators() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final collaborators = await _service.getCollaborators(widget.memorialId);
      setState(() {
        _collaborators = collaborators;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
        _collaborators = [];
      });
    }
  }
  
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('SocketException') || 
        errorString.contains('Connection')) {
      return 'No hay conexión a internet';
    }
    
    if (errorString.contains('404')) {
      return 'Memorial no encontrado';
    }
    
    if (errorString.contains('401') || errorString.contains('403')) {
      return 'No tienes permisos para gestionar colaboradores';
    }
    
    return 'Error al cargar colaboradores';
  }
  
  void _showInviteOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Título
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Invitar colaborador',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ✅ NUEVA OPCIÓN: WhatsApp
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble,
                    color: Color(0xFF25D366),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Invitar por WhatsApp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Genera un código y compártelo',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await showDialog(
                    context: context,
                    builder: (context) => InviteByWhatsAppDialog(
                      memorialId: widget.memorialId,
                      memorialName: widget.memorialName,
                    ),
                  );
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invitación compartida por WhatsApp'),
                        backgroundColor: Color(0xFF25D366),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              
              const Divider(height: 1),
              
              // Opción: Email directo
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.email,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Invitar por email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Envía una invitación directa',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await showDialog(
                    context: context,
                    builder: (context) => InviteByEmailDialog(
                      memorialId: widget.memorialId,
                    ),
                  );
                  if (result == true) {
                    _loadCollaborators();
                  }
                },
              ),
              
              const Divider(height: 1),
              
              // Opción: Código
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Color(0xFF4ECDC4),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Generar código',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Comparte un código de invitación',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => GenerateInviteCodeDialog(
                      memorialId: widget.memorialId,// ✅ Pasar el nombre
                      onGenerated: (code) {},
                    ),
                  );
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Código generado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _updatePermissions(CollaboratorResponse collaborator) async {
    showDialog(
      context: context,
      builder: (context) => _PermissionsDialog(
        collaborator: collaborator,
        onSave: (canEdit, canComment) async {
          try {
            await _service.updateCollaborator(
              collaborator.idCollaborator,
              canEdit: canEdit,
              canComment: canComment,
            );
            
            await _loadCollaborators();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permisos actualizados'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al actualizar: ${_getErrorMessage(e)}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
  
  Future<void> _removeCollaborator(CollaboratorResponse collaborator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quitar colaborador'),
        content: Text(
          '¿Estás seguro de quitar a ${collaborator.userName ?? collaborator.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _service.removeCollaborator(collaborator.idCollaborator);
        await _loadCollaborators();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Colaborador eliminado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${_getErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Colaboradores',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: _loadCollaborators,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteOptions,
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Invitar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            SizedBox(height: 16),
            Text('Cargando...'),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCollaborators,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_collaborators.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadCollaborators,
      color: const Color(0xFFFF6B6B),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _collaborators.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final collaborator = _collaborators[i];
          return _CollaboratorCard(
            collaborator: collaborator,
            onUpdatePermissions: () => _updatePermissions(collaborator),
            onRemove: () => _removeCollaborator(collaborator),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 80,
                color: const Color(0xFFFF6B6B).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay colaboradores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invita a amigos y familiares a colaborar\nen este memorial',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Los widgets _CollaboratorCard y _PermissionsDialog quedan igual...
class _CollaboratorCard extends StatelessWidget {
  final CollaboratorResponse collaborator;
  final VoidCallback onUpdatePermissions;
  final VoidCallback onRemove;
  
  const _CollaboratorCard({
    required this.collaborator,
    required this.onUpdatePermissions,
    required this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) {
    final isActive = collaborator.status == 'active';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E4EA)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 2),
            color: Color(0x0F000000),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
            child: Text(
              (collaborator.userName ?? collaborator.email)[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collaborator.userName ?? collaborator.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle : Icons.schedule,
                      size: 14,
                      color: isActive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Activo' : 'Pendiente',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Editar: ${collaborator.canEdit ? "Sí" : "No"}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'permissions') onUpdatePermissions();
              if (value == 'remove') onRemove();
            },
            itemBuilder: (context) => [
              if (isActive)
                const PopupMenuItem(
                  value: 'permissions',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Editar permisos'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Quitar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionsDialog extends StatefulWidget {
  final CollaboratorResponse collaborator;
  final Function(bool canEdit, bool canComment) onSave;
  
  const _PermissionsDialog({
    required this.collaborator,
    required this.onSave,
  });
  
  @override
  State<_PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<_PermissionsDialog> {
  late bool _canEdit;
  late bool _canComment;
  
  @override
  void initState() {
    super.initState();
    _canEdit = widget.collaborator.canEdit;
    _canComment = widget.collaborator.canComment;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Editar permisos'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Puede editar'),
            subtitle: const Text('Crear y modificar contenido'),
            value: _canEdit,
            onChanged: (value) => setState(() => _canEdit = value),
            activeColor: const Color(0xFFFF6B6B),
          ),
          // SwitchListTile(
          //   title: const Text('Puede comentar'),
          //   subtitle: const Text('Agregar comentarios'),
          //   value: _canComment,
          //   onChanged: (value) => setState(() => _canComment = value),
          //   activeColor: const Color(0xFFFF6B6B),
          // ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_canEdit, _canComment);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}