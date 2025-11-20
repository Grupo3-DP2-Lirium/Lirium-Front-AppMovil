import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/select_memorial_capsule_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_preview_screen.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';

class CapsulesTab extends StatefulWidget {
  const CapsulesTab({super.key});

  @override
  State<CapsulesTab> createState() => _CapsulesTabState();
}

class _CapsulesTabState extends State<CapsulesTab> {
  String _selectedFilter = 'drafts'; // 'drafts' o 'published'
  bool canUseIA = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CapsuleProvider>().loadMyCapsules();
      final subscriptionProvider = context.read<SubscriptionProvider>();
      final permissions = subscriptionProvider.permissions; // lista de permisos
      setState(() {
        canUseIA = permissions.contains('IA_FEATURES');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final capsuleProvider = context.watch<CapsuleProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    canUseIA = subscriptionProvider.permissions.contains('IA_FEATURES');

    if (capsuleProvider.loading && capsuleProvider.capsules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final draftCapsules = capsuleProvider.draftCapsules;
    final publishedCapsules = capsuleProvider.publishedCapsules;

    // Determinar qué mostrar según el filtro
    final capsulesFilteredToShow = _selectedFilter == 'drafts'
        ? draftCapsules
        : publishedCapsules;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => capsuleProvider.loadMyCapsules(force: true),
          child: draftCapsules.isEmpty && publishedCapsules.isEmpty
              ? _buildEmptyState()
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎨 Chips de filtro suaves
              _buildFilterChips(draftCapsules.length, publishedCapsules.length),

              // Lista de cápsulas
              Expanded(
                child: capsulesFilteredToShow.isEmpty
                    ? _buildEmptyFilterState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  itemCount: capsulesFilteredToShow.length,
                  itemBuilder: (context, index) {
                    final capsule = capsulesFilteredToShow[index];
                    return CapsuleCard(
                      capsule: capsule,
                      onTap: () => _navigateToPreview(capsule),
                      onDelete: () => _confirmDelete(capsule),
                      onCancel: capsule.isProcessing
                          ? () => _confirmCancel(capsule)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // FAB - Crear cápsula
        if (draftCapsules.isNotEmpty || publishedCapsules.isNotEmpty)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToCreate(),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Crear Cápsula',
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

  /// Estado vacío cuando no hay cápsulas filtradas
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
                  : 'No tienes cápsulas publicadas',
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
                  ? 'Crea una cápsula para empezar'
                  : 'Publica tus cápsulas completadas',
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

  /// Estado vacío general (sin ninguna cápsula)
  Widget _buildEmptyState() {
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
                Icons.video_library_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes cápsulas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una cápsula para revivir un momento especial en formato vertical',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Crear mi primera cápsula',
              icon: Icons.add,
              onPressed: () {
                if (canUseIA) {
                  _navigateToCreate();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectMemorialCapsuleScreen(),
      ),
    );
  }

  void _navigateToPreview(CapsuleModel capsule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CapsulePreviewScreen(capsule: capsule),
      ),
    );
  }

  void _confirmDelete(CapsuleModel capsule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cápsula'),
        content: Text('¿Estás seguro de eliminar "${capsule.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<CapsuleProvider>();
              final success = await provider.deleteCapsule(capsule.idCapsule);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cápsula eliminada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(CapsuleModel capsule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar procesamiento'),
        content: Text('¿Cancelar la generación de "${capsule.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<CapsuleProvider>();
              await provider.cancelCapsule(capsule.idCapsule);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}