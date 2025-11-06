import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/videos/components/documentary_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/select_memorial_documentary_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentary_detail_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';

class DocumentariesTab extends StatefulWidget {
  const DocumentariesTab({super.key});

  @override
  State<DocumentariesTab> createState() => _DocumentariesTabState();
}

class _DocumentariesTabState extends State<DocumentariesTab>
    with SingleTickerProviderStateMixin {
  late TabController _filterTabController;

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 2, vsync: this);
  }

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
        // Filtros: Publicados | Borradores (chips estilo suave)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _filterTabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.transparent,
            labelColor: AppColors.primary, // texto rosado cuando está seleccionado
            unselectedLabelColor: Colors.grey[700],

            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              //Publicados
              Tab(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 6),
                      const Text('Publicados'),
                      if (provider.publishedDocumentaries.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${provider.publishedDocumentaries.length}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              //Borradores
              Tab(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_note, size: 16),
                      const SizedBox(width: 6),
                      const Text('Borradores'),
                      if (provider.draftDocumentaries.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${provider.draftDocumentaries.length}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),






        // Contenido con tabs
        Expanded(
          child: TabBarView(
            controller: _filterTabController,
            children: [
              _buildDocumentaryList(provider.publishedDocumentaries, provider),
              _buildDocumentaryList(provider.draftDocumentaries, provider),

            ],
          ),
        ),

        // Botón crear
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
                  builder: (_) => const SelectMemorialDocumentaryScreen(),
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

  Widget _buildDocumentaryList(List documentaries, DocumentaryProvider provider) {
    if (documentaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _filterTabController.index == 0
                  ? 'No hay borradores'
                  : 'No hay documentales publicados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMyDocumentaries(force: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: documentaries.length,
        itemBuilder: (context, index) {
          final documentary = documentaries[index];
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
            onDelete: () => _showDeleteDialog(context, documentary, provider),
            onCancel: documentary.isProcessing
                ? () => _showCancelDialog(context, documentary, provider)
                : null,
          );
        },
      ),
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
                    builder: (_) => const SelectMemorialDocumentaryScreen(),
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

  void _showDeleteDialog(BuildContext context, documentary, DocumentaryProvider provider) {
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

  void _showCancelDialog(BuildContext context, documentary, DocumentaryProvider provider) {
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

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }
}