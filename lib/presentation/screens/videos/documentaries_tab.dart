import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/screens/videos/components/documentary_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/create_documentary_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentary_detail_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';

class DocumentariesTab extends StatelessWidget {
  const DocumentariesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentaryProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${provider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadMyDocumentaries(force: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.documentaries.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadMyDocumentaries(force: true),
            color: const Color(0xFF6366F1),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.documentaries.length,
              itemBuilder: (context, index) {
                final documentary = provider.documentaries[index];
                return DocumentaryCard(
                  documentary: documentary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentaryDetailScreen(
                          documentaryId: documentary.idDocumentary,
                        ),
                      ),
                    ).then((_) {
                      provider.loadMyDocumentaries(force: true);
                    });
                  },
                  onDelete: () => _showDeleteDialog(context, documentary),
                  onCancel: documentary.isProcessing
                      ? () => _showCancelDialog(context, documentary)
                      : null,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            text: 'Nuevo Documental',
            icon: Icons.movie_creation_outlined,
            isFullWidth: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateDocumentaryScreen(),
                ),
              ).then((_) {
                provider.loadMyDocumentaries(force: true);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes documentales aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Crea tu primer documental para recordar momentos especiales',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: PrimaryButton(
              text: 'Crear Documental',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateDocumentaryScreen(),
                  ),
                ).then((_) {
                  context.read<DocumentaryProvider>().loadMyDocumentaries(force: true);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, documentary) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar documental'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este documental? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<DocumentaryProvider>();
              final success = await provider.deleteDocumentary(
                documentary.idDocumentary,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Documental eliminado'
                          : 'Error al eliminar documental',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, documentary) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar generación'),
        content: const Text(
          '¿Deseas cancelar la generación de este documental?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<DocumentaryProvider>();
              final success = await provider.cancelDocumentary(
                documentary.idDocumentary,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Generación cancelada'
                          : 'Error al cancelar',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}