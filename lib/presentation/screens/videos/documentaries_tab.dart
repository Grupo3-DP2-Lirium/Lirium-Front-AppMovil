import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/videos/components/documentary_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/select_memorial_documentary_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentary_detail_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/plan_provider.dart';

class DocumentariesTab extends StatefulWidget {
  const DocumentariesTab({super.key});

  @override
  State<DocumentariesTab> createState() => _DocumentariesTabState();
}

class _DocumentariesTabState extends State<DocumentariesTab> {
  String _selectedFilter = 'drafts'; // 'drafts' o 'published'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentaryProvider>();

    if (provider.loading && provider.documentaries.isEmpty) {
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

    final draftDocumentaries = provider.draftDocumentaries;
    final publishedDocumentaries = provider.publishedDocumentaries;

    // Determinar qué mostrar según el filtro
    final documentariesToShow = _selectedFilter == 'drafts'
        ? draftDocumentaries
        : publishedDocumentaries;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => provider.loadMyDocumentaries(force: true),
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎨 Chips de filtro suaves
              _buildFilterChips(draftDocumentaries.length, publishedDocumentaries.length),

              // Lista de documentales
              Expanded(
                child: documentariesToShow.isEmpty
                    ? _buildEmptyFilterState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: documentariesToShow.length,
                  itemBuilder: (context, index) {
                    final documentary = documentariesToShow[index];
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
              ),
            ],
          ),
        ),

        // FAB - Crear documental
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
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
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Crear Documental',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎨 Chips de filtro suaves
  Widget _buildFilterChips(int draftsCount, int publishedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Borradores',
            value: 'drafts',
            count: draftsCount,
            icon: Icons.edit_note,
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            label: 'Publicados',
            value: 'published',
            count: publishedCount,
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required int count,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Estado vacío cuando no hay documentales filtrados
  Widget _buildEmptyFilterState() {
    final isDrafts = _selectedFilter == 'drafts';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDrafts ? Icons.edit_note : Icons.public_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isDrafts
                  ? 'No tienes borradores'
                  : 'No tienes documentales publicados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDrafts
                  ? 'Crea un documental para empezar'
                  : 'Publica tus documentales completados',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío general (sin ningún documental)
  Widget _buildEmptyState(BuildContext context) {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final subscription = subscriptionProvider.subscription;
    final maxDocs =  0;

    final canCreate = true;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.movie_creation_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes documentales aún',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer documental para recordar momentos especiales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: canCreate
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectMemorialDocumentaryScreen(),
                  ),
                ).then((_) {
                  context.read<DocumentaryProvider>().loadMyDocumentaries(force: true);
                });
              }
                  : null, // deshabilitado si no puede crear
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                canCreate
                    ? 'Crear mi primer documental'
                    : 'No puedes crear documentales con tu plan',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canCreate ? AppColors.primary : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
}