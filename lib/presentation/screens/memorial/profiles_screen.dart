import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/accept_invite_code_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MemorialProvider>();
      provider.cargarMisMemoriales();
      provider.cargarColaborativos();
    });
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    if (_tabController.index == 0) {
      // Tab "Mis Memoriales" - Botón crear
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: PrimaryButton(
          text: 'Nuevo Memorial',
          icon: Icons.add,
          isFullWidth: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewMemorialRelationScreen()),
            );
          },
        ),
      );
    } else {
      // Tab "Colaboraciones" - Botón ingresar código
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B4CE6), Color(0xFF8B6CEF)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4CE6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.qr_code, color: Colors.white, size: 24),
            label: const Text(
              'Ingresar código',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMisMemoriales(MemorialProvider provider) {
    if (provider.cargandoMis) {
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
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No tienes memoriales aún",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                "Crea tu primer memorial para empezar",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.cargarMisMemoriales(force: true),
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: provider.misMemoriales.length,
        itemBuilder: (context, index) {
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
              ).then((_) => provider.cargarMisMemoriales(force: true));
            },
          );
        },
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
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No colaboras en ningún memorial",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                "Ingresa un código para unirte",
                style: TextStyle(color: Colors.grey[500]),
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
                MaterialPageRoute(
                  builder: (_) => MemorialDetailScreen(memorialId: m.idMemorial),
                ),
              ).then((_) => provider.cargarColaborativos(force: true));
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