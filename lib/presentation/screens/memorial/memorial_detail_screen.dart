import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_actions.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_details_state.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_header.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_tabs.dart';
import 'package:flutter_frontend/presentation/screens/memorial/widgets/memorial_options_menu.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/memories_tab.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/videos_tab.dart';
import 'package:flutter_frontend/presentation/screens/memorial/tabs/info_tab.dart';
import 'package:flutter_frontend/presentation/screens/memorial/edit_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborative_memorials/collaborators_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/create_memory_select_type.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/providers/memories_by_memorial_provider.dart';

class MemorialDetailScreen extends StatefulWidget {
  final String memorialId;

  const MemorialDetailScreen({super.key, required this.memorialId});

  @override
  State<MemorialDetailScreen> createState() => _MemorialDetailScreenState();
}

class _MemorialDetailScreenState extends State<MemorialDetailScreen> {
  final MemorialService _memorialService = MemorialService();
  final MemorialActions _memorialActions = MemorialActions();
  final ScrollController _scrollController = ScrollController();

  // Estado principal
  MemorialDetailsState _detailsState = MemorialDetailsState();
  String? coverUrl;

  // Estado de carga
  bool isLoadingMemorial = true;
  String? memorialErrorMessage;

  // UI State
  bool _isHeaderCollapsed = false;
  int _selectedTopTab = 0;

  @override
  void initState() {
    super.initState();

    // FIX: Limpiar provider ANTES de cargar datos del nuevo memorial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<MemoriesByMemorialProvider>();

        // Si es un memorial diferente al actual, limpiar
        if (provider.currentMemorialId != null &&
            provider.currentMemorialId != widget.memorialId) {
          print('🧹 Limpiando provider - memorial anterior: ${provider.currentMemorialId}');
          provider.clear();
        }
      }
    });

    _loadMemorialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldCollapse = _scrollController.offset > 100;
    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = shouldCollapse);
    }
  }

  Future<void> _loadMemorialData() async {
    try {
      setState(() {
        isLoadingMemorial = true;
        memorialErrorMessage = null;
      });

      final memorial = await _memorialService.getMemorialById(widget.memorialId);
      if (!mounted) return;

      setState(() {
        _detailsState = MemorialDetailsState.fromResponse(memorial);
        isLoadingMemorial = false;
      });
    } catch (e) {
      setState(() {
        memorialErrorMessage = 'Error al cargar el memorial: $e';
        isLoadingMemorial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final hasPremiumPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

    if (!subProvider.isLoaded || isLoadingMemorial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (memorialErrorMessage != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header expandible
              MemorialHeader(
                detailsState: _detailsState,
                coverUrl: coverUrl,
                isHeaderCollapsed: _isHeaderCollapsed,
                onBack: () => Navigator.pop(context),
              ),

              // Tabs principales
              MemorialTabs(
                selectedTab: _selectedTopTab,
                onTabChanged: (index) => setState(() => _selectedTopTab = index),
              ),

              // Esto permite que el contenido sea parte del mismo scroll
              SliverToBoxAdapter(
                child: _buildTabContent(),
              ),
            ],
          ),

          // Botón flotante
          _buildFloatingButton(hasPremiumPermission),

          // Botón de configuración
          if (_detailsState.isOwner || _detailsState.canEdit)
            _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTopTab) {
      case 0:
        return MemoriesTab(
          memorialId: widget.memorialId,
          //IMPORTANTE: Pasar el scrollController para que no tenga scroll propio
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      case 1:
        return VideosTab(
          memorialId: widget.memorialId,
          //IMPORTANTE: Pasar el scrollController para que no tenga scroll propio
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      case 2:
        return InfoTab(detailsState: _detailsState);
      default:
        return MemoriesTab(
          memorialId: widget.memorialId,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
    }
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: _isHeaderCollapsed ? Colors.white : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: _isHeaderCollapsed
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: _isHeaderCollapsed ? AppColors.primary : Colors.white,
          ),
          onPressed: () => _showMemorialOptionsMenu(context),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(bool hasPremiumPermission) {
    return Positioned(
      bottom: 24,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () {
          if (hasPremiumPermission) {
            _goToCreateMemory();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
            );
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear Recuerdo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              Text(
                memorialErrorMessage!,
                textAlign: TextAlign.center,
                style: AppColors.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loadMemorialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToCreateMemory() async {
    final createdMemory = await Navigator.push<Memory>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMemorySelectType(
          memorialId: _detailsState.idMemorial,
          memorialName: _detailsState.name,
          isFromMemorial: true,
        ),
      ),
    );

    if (createdMemory != null && mounted) {
      print('🆕 Memoria creada recibida:');
      print('   - ID: ${createdMemory.id}');
      print('   - Título: ${createdMemory.title}');
      print('   - Files: ${createdMemory.files.length}');
      print('- Momentos: ${createdMemory.moments.length}');
      print('- Categorías: ${createdMemory.categories.length}');

      for (var i = 0; i < createdMemory.files.length; i++) {
        final file = createdMemory.files[i];
        print('   - File $i:');
        print('     * Type: ${file.type}');
        print('     * URL: ${file.url}');
        print('     * downloadUrl: ${file.url}');
        print('     * Tiene URL? ${file.url != null && file.url!.isNotEmpty}');
      }

      // Agregar al provider
      final memoriesProvider = context.read<MemoriesByMemorialProvider>();
      memoriesProvider.addMemory(createdMemory);
    }
  }

  void _showMemorialOptionsMenu(BuildContext context) {
    MemorialOptionsMenu.show(
      context,
      isOwner: _detailsState.isOwner,
      canEdit: _detailsState.canEdit,
      isCollaborative: _detailsState.isCollaborative,
      memorialId: widget.memorialId,
      memorialName: _detailsState.name,
      onEdit: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMemorialScreen(memorialId: widget.memorialId),
          ),
        ).then((value) {
          if (value == true) {
            _loadMemorialData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cambios guardados'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
      },
      onDelete: () async {
        await _memorialActions.deleteMemorial(context, widget.memorialId);
      },
      onShare: () async {
        await _memorialActions.shareMemorial(context, widget.memorialId);
      },
      onManageCollaborators: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollaboratorsScreen(
              memorialId: widget.memorialId,
              memorialName: _detailsState.name,
            ),
          ),
        );
      },
    );
  }
}