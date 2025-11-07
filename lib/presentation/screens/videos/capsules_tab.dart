import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/capsule_model.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/select_memorial_capsule_screen.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_preview_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';

class CapsulesTab extends StatefulWidget {
  const CapsulesTab({super.key});

  @override
  State<CapsulesTab> createState() => _CapsulesTabState();
}

class _CapsulesTabState extends State<CapsulesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CapsuleProvider>().loadMyCapsules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final capsuleProvider = context.watch<CapsuleProvider>();

    if (capsuleProvider.loading && capsuleProvider.capsules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final draftCapsules = capsuleProvider.draftCapsules;
    final publishedCapsules = capsuleProvider.publishedCapsules;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => capsuleProvider.loadMyCapsules(force: true),
          child: draftCapsules.isEmpty && publishedCapsules.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mis cápsulas (drafts + processing + completed)
                if (draftCapsules.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis Cápsulas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (capsuleProvider.hasProcessingCapsules)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.purple[600]!),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Procesando',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...draftCapsules.map((capsule) => CapsuleCard(
                    capsule: capsule,
                    onTap: () => _navigateToPreview(capsule),
                    onDelete: () => _confirmDelete(capsule),
                    onCancel: capsule.isProcessing
                        ? () => _confirmCancel(capsule)
                        : null,
                  )),
                  const SizedBox(height: 24),
                ],

                // Cápsulas publicadas
                if (publishedCapsules.isNotEmpty) ...[
                  const Text(
                    'Publicadas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...publishedCapsules.map((capsule) => CapsuleCard(
                    capsule: capsule,
                    onTap: () => _navigateToPreview(capsule),
                    onDelete: () => _confirmDelete(capsule),
                  )),
                ],

                const SizedBox(height: 80), // Espacio para FAB
              ],
            ),
          ),
        ),

        // FAB - Crear cápsula
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
              onPressed: () => _navigateToCreate(),
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