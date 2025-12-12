import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/support/report_user_screen.dart';

class CollaboratorActionsMenu extends StatelessWidget {
  final String memorialId;
  final String memorialName;
  final String collaboratorId;
  final String collaboratorName;
  final VoidCallback? onRemoveUser;

  const CollaboratorActionsMenu({
    super.key,
    required this.memorialId,
    required this.memorialName,
    required this.collaboratorId,
    required this.collaboratorName,
    this.onRemoveUser,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      ),
      onSelected: (value) {
        if (value == 'report') {
          _showReportUser(context);
        } else if (value == 'remove') {
          _showRemoveUser(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.report_outlined, size: 18, color: Colors.orange),
              SizedBox(width: 12),
              Text('Reportar usuario'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_remove, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Eliminar usuario', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportUserScreen(
          reportedUserId: collaboratorId,
          reportedUserName: collaboratorName,
          memorialId: memorialId,
          memorialName: memorialName,
        ),
      ),
    );
  }

  void _showRemoveUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de eliminar a $collaboratorName del memorial "$memorialName"?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_outlined, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onRemoveUser != null) {
                onRemoveUser!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
