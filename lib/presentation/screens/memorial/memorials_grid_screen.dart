import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborative_memorials/accept_invite_code_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import '../../components/components.dart';
import 'package:provider/provider.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userPlan;
  List<String>? userPermissions;

  bool canCreateMemorials = false;
  bool canUseIA = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Recargar cuando cambien tabs
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Cargar plan y permisos
    _loadUserPlanAndPermissions();
    // cargar data después de que el widget se haya montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MemorialProvider>();
      provider.cargarMisMemoriales();
      provider.cargarColaborativos();
    });
  }

  Future<void> _loadUserPlanAndPermissions() async {
    // Setear bools según permisos
    canCreateMemorials = userPermissions?.contains('CREATE_MEMORIALS') ?? false;
    canUseIA = userPermissions?.contains('IA_FEATURES') ?? false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.13;
    final provider = context.watch<MemorialProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: 'Memoriales',
        onBack: () => Navigator.pop(context),
        tabController: _tabController,
        showBackButton: false,
        appBarHeight: appBarHeight,
        tabs: const [
          Tab(text: 'Mis Memoriales'),
          Tab(text: 'Colaboraciones'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMisMemoriales(provider),
          _buildCollaborationTab(provider)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    final provider = context.watch<MemorialProvider>();

    // Si estamos en la pestaña "Mis Memoriales"
    if (_tabController.index == 0) {
      // Si NO hay memoriales -> no queremos FAB flotando, ya se muestra en el empty state
      if (provider.misMemoriales.isEmpty) return null;

      // Si hay memoriales -> mostramos un FAB flotante
      final subProvider = context.read<SubscriptionProvider>();
      final hasPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

      return FloatingActionButton.extended(
        onPressed: () {
          if (hasPermission) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
            ).then((_) {
              // refrescar al volver
              provider.cargarMisMemoriales(force: true);
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
            ).then((_) async {
              await _loadUserPlanAndPermissions();
            });
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear Memorial',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      );
    }

    // Si estamos en la pestaña "Colaboraciones"
    else {
      // Si NO hay colaboraciones -> no mostrar FAB, ya se muestra en el empty state
      if (provider.colaborativos.isEmpty) return null;

      // Si hay colaboraciones -> mostramos el botón flotante para "Ingresar código"
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6B4CE6),
              Color(0xFF8B6CEF),
            ],
          ),
          borderRadius: BorderRadius.circular(16), // para matching con el FAB extended
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AcceptInviteCodeScreen()),
            );
            if (result == true && mounted) {
              provider.cargarColaborativos(force: true);
            }
          },
          icon: const Icon(Icons.qr_code, color: Colors.white),
          label: const Text(
            'Ingresar código',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }


  Widget _buildMisMemoriales(MemorialProvider provider) {
    if (provider.misMemoriales.isEmpty && provider.cargandoMis) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMis != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Error: ${provider.errorMis}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.cargarMisMemoriales(force: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (provider.misMemoriales.isEmpty) {
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
                  Icons.auto_awesome,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aún no tienes memoriales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Crea un memorial para preservar los recuerdos de quienes más amas',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Crear mi primer memorial',
                icon: Icons.add,
                onPressed: () {
                  final subProvider = context.read<SubscriptionProvider>();
                  final hasPermission = subProvider.permissions.contains("CREATE_MEMORIALS");
                  // Verificar permisos / plan
                  if (hasPermission) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                    ).then((_) async {
                      // Se ejecuta al volver
                      await _loadUserPlanAndPermissions();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.cargarMisMemoriales(force: true),
      color: const Color(0xFF6366F1),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!provider.cargandoMis &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            provider.cargarMisMemoriales();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: provider.misMemoriales.length + 1,
          itemBuilder: (context, index) {

            // 👇 este check es CLAVE
            if (index == provider.misMemoriales.length) {
              return provider.cargandoMis
                  ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox.shrink();
            }

            final m = provider.misMemoriales[index];

            return ProfileCard(
              name: m.name,
              description: m.description,
              profilePhotoBase64: m.profilePhotoBase64,
              profilePhotoUrl: m.profilePhotoUrl,
              isShared: m.isCollaborative,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemorialDetailScreen(memorialId: m.idMemorial),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCollaborationTab(MemorialProvider provider) {
    if (provider.cargandoColab) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorColab != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Error: ${provider.errorColab}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.cargarColaborativos(force: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (provider.colaborativos.isEmpty) {
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
                  Icons.people_outline_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aún no tienes colaboraciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa un código para unirte y compartir momentos especiales.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Ingresar código',
                icon: Icons.qr_code,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6B4CE6),
                    Color(0xFF8B6CEF),
                  ],
                ),
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AcceptInviteCodeScreen(),
                    ),
                  );

                  if (result == true && mounted) {
                    final provider = context.read<MemorialProvider>();
                    provider.cargarColaborativos(force: true);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.cargarColaborativos(force: true),
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: provider.colaborativos.length,
        itemBuilder: (context, index) {
          final m = provider.colaborativos[index];
          return ProfileCard(
            name: m.name,
            description: m.description,
            profilePhotoBase64: m.profilePhotoBase64,
            profilePhotoUrl: m.profilePhotoUrl,
            isShared: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MemorialDetailScreen(memorialId: m.idMemorial)),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}