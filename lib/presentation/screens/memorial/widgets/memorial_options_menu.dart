import 'package:flutter/material.dart';

class MemorialOptionsMenu {
  static void show(
    BuildContext context, {
    required bool isOwner,
    required bool canEdit,
    required bool isCollaborative,
    required String memorialId,
    required String? memorialName,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onShare,
    required VoidCallback onManageCollaborators,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra superior
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Configuración del memorial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                
                const Divider(),
                
                // EDITAR: Solo si es dueño o colaborador con permiso
                if (canEdit || isOwner)
                  _buildMenuItem(
                    icon: Icons.edit,
                    title: 'Editar memorial',
                    subtitle: 'Modificar información básica',
                    color: const Color(0xFF6366F1),
                    onTap: onEdit,
                  ),
                
                if (canEdit || isOwner) const Divider(height: 1),
                
                // GESTIONAR COLABORADORES: Solo dueño
                if (isOwner && isCollaborative) ...[
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'Gestionar colaboradores',
                    subtitle: 'Invitar y administrar permisos',
                    color: const Color(0xFF6B4CE6),
                    onTap: onManageCollaborators,
                  ),
                  const Divider(height: 1),
                ],
                
                // COMPARTIR: Solo dueño
                if (isOwner) ...[
                  _buildMenuItem(
                    icon: Icons.share,
                    title: 'Compartir memorial',
                    subtitle: 'Generar link para compartir',
                    color: const Color(0xFF10B981),
                    onTap: onShare,
                  ),
                  const Divider(height: 1),
                ],
                
                // ELIMINAR: Solo dueño
                if (isOwner)
                  _buildMenuItem(
                    icon: Icons.delete,
                    title: 'Eliminar memorial',
                    subtitle: 'Esta acción no se puede deshacer',
                    color: Colors.red,
                    onTap: onDelete,
                  ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color == Colors.red ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }
}
