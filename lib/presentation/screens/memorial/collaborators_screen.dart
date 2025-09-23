// lib/screens/memorial/collaborators_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';

enum CollaboratorStatus { active, pending }

class CollaboratorItem {
  final String id;
  final String name;
  final String? avatarUrl;
  final CollaboratorStatus status;

  CollaboratorItem({
    required this.id,
    required this.name,
    required this.status,
    this.avatarUrl,
  });
}

class CollaboratorsScreen extends StatelessWidget {
  final String memorialId;

  const CollaboratorsScreen({
    super.key,
    required this.memorialId,
  });

  // MOCK
  List<CollaboratorItem> _mock() => [
    CollaboratorItem(
      id: '1',
      name: 'Ana Pérez',
      status: CollaboratorStatus.active,
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
    ),
    CollaboratorItem(
      id: '2',
      name: 'Juan Gómez',
      status: CollaboratorStatus.pending,
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final items = _mock();

    Color statusColor(CollaboratorStatus s) =>
        s == CollaboratorStatus.active ? const Color(0xFF2E7D32) : Colors.black54;

    String statusText(CollaboratorStatus s) =>
        s == CollaboratorStatus.active ? 'Estado: Activo' : 'Estado: Invitación pendiente';

    String quickActionText(CollaboratorStatus s) =>
        s == CollaboratorStatus.active ? 'Quitar acceso' : 'Quitar';

    void removeAction(String name) {
      // TODO: acción real de quitar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Quitado: $name')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Colaboradores',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Lista sin contenedor envolvente
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final it = items[i];
                return _CollaboratorCard(
                  item: it,
                  statusColor: statusColor(it.status),
                  statusText: statusText(it.status),
                  //quickActionText: quickActionText(it.status),
                  onQuickAction: () => removeAction(it.name),
                  onMenuRemove: () => removeAction(it.name), // 3 puntos -> Quitar
                );
              },
            ),
          ),
          // Botón fijo inferior
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PrimaryButton(
              text: 'Invitar a colaborador',
              onPressed: () {
                // TODO: flujo de invitación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitar a colaborador (mock)')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaboratorCard extends StatelessWidget {
  final CollaboratorItem item;
  final Color statusColor;
  final String statusText;
  //final String quickActionText;
  final VoidCallback onQuickAction;
  final VoidCallback onMenuRemove; // único ítem del menú

  const _CollaboratorCard({
    required this.item,
    required this.statusColor,
    required this.statusText,
    //required this.quickActionText,
    required this.onQuickAction,
    required this.onMenuRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Foto
          CircleAvatar(
            radius: 22,
            backgroundImage: item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
            child: item.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          // Nombre + estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(statusText, style: tt.bodyMedium?.copyWith(color: statusColor)),
              ],
            ),
          ),
          // Acción rápida + menú
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'remove') onMenuRemove();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'remove', child: Text('Quitar')),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
