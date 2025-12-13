import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/components/documentary_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/select_memorial_documentary_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentary_detail_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/plan_provider.dart';

class DocumentariesTab extends StatefulWidget {
  final DocumentaryProvider provider;

  const DocumentariesTab(this.provider, {super.key});

  @override
  State<DocumentariesTab> createState() => _DocumentariesTabState();
}

class _DocumentariesTabState extends State<DocumentariesTab> {
  String _selectedFilter = 'drafts'; // 'drafts' o 'published'

  @override
  void initState() {
    super.initState();
    print('🎬 DocumentariesTab initState');
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final maxDocs = subscriptionProvider.subscription?.maxDocumentariesPerMonth ?? 0;
    final now = DateTime.now();
    final totalDocsThisMonth = provider.documentaries.where((doc) {
      final createdAt = doc.createdDate;
      return createdAt.year == now.year && createdAt.month == now.month;
    }).length;

    print('🎬 DocumentariesTab build - loading: ${provider.loading}, docs: ${provider.documentaries.length}, error: ${provider.error}');

    if (provider.loading && provider.documentaries.isEmpty) {
      print('⏳ Showing loading indicator');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando documentales...'),
          ],
        ),
      );
    }

    if (provider.error != null) {
      print('❌ Showing error: ${provider.error}');
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
              onPressed: () {
                print('🔄 Retry button pressed');
                provider.loadMyDocumentaries(force: true);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.documentaries.isEmpty) {
      print('📭 Showing empty state');
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
              if (maxDocs == 0) {
                // Plan gratuito o sin límite → redirigir a GetPremium
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                );
              } else if (totalDocsThisMonth < maxDocs) {
                // Puede crear un nuevo documental
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectMemorialDocumentaryScreen()),
                ).then((_) {
                  provider.loadMyDocumentaries(force: true);
                });
              } else {
                // Alcanzó límite mensual
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No puedes crear más documentales este mes')),
                );
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Crear Documental',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: (totalDocsThisMonth < maxDocs)
                ? AppColors.primary  // tu rosa
                : Colors.grey,
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
    final documentaryProvider = context.read<DocumentaryProvider>();

    final maxDocs = subscriptionProvider.subscription?.maxDocumentariesPerMonth;
    final now = DateTime.now();
    final totalDocsThisMonth = documentaryProvider.documentaries.where((doc) {
      final createdAt = doc.createdDate;
      return createdAt.year == now.year && createdAt.month == now.month;
    }).length;

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
              'Aún no tienes documentales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer documental para recordar momentos significativos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Si maxDocs es 0 o null → redirigir a GetScreen
                if (maxDocs == 0 || maxDocs == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                  );
                } else {
                  // Validar si puede crear según límite
                  if (totalDocsThisMonth < maxDocs) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SelectMemorialDocumentaryScreen()),
                    ).then((_) {
                      documentaryProvider.loadMyDocumentaries(force: true);
                    });
                  } else {
                    // Opcional: mostrar toast o dialog que ya alcanzó límite
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No puedes crear más documentales con tu plan')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                (maxDocs == 0 || maxDocs == null || totalDocsThisMonth < maxDocs)
                    ? 'Crear mi primer documental'
                    : 'No puedes crear más documentales con tu plan',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (maxDocs == 0 || maxDocs == null || totalDocsThisMonth < maxDocs)
                    ? AppColors.primary
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (maxDocs != null && maxDocs > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Documentales creados este Mes: $totalDocsThisMonth / $maxDocs',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      documentary,
      DocumentaryProvider provider,
      ) {
    appPopupButtonDefault(
      context: context,
      title: 'Eliminar documental',
      message:
      '¿Estás seguro de que deseas eliminar este documental? Esta acción no se puede deshacer.',
      buttons: [
        AppPopupButton(
          text: 'Cancelar',
          onPressed: () {
            Navigator.pop(context); // Cierra el popup de confirmación
          },
        ),
        AppPopupButton(
          text: 'Eliminar',
          onPressed: () async {
            // Cerrar popup de confirmación
            Navigator.pop(context);

            // Mostrar popup de loading
            appPopupButtonDefault(
                context: context,
                title: "",
                message: "",
                buttons: [AppPopupButton(text: "", onPressed: () {})],
                isLoading: true,
            );

            // Ejecutar la operación async
            final success = await provider.deleteDocumentary(
              documentary.idDocumentary,
            );

            // Cerrar popup de loading
            if (context.mounted) Navigator.pop(context);

            // Mostrar resultado
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Documental eliminado' : 'Error al eliminar documental',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
        ),
      ],
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