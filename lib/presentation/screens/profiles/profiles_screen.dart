import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
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

    // cargar data después de que el widget se haya montado
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
          Tab(text: 'Mis Perfiles'),
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

      // Boton para crear Memorial
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _tabController.index == 0
          ? Padding(
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
      )
          : null,
    );
  }

  Widget _buildMisMemoriales(MemorialProvider provider) {
    if (provider.cargandoMis) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMis != null) {
      return Center(child: Text("Error: ${provider.errorMis}"));
    }
    if (provider.misMemoriales.isEmpty) {
      return const Center(child: Text("No tienes memoriales aún"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Forzar recarga completa
        await provider.cargarMisMemoriales(force: true);
      },
      color: const Color(0xFF6366F1), // Color del spinner
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
                  builder: (_) => MemorialDetailScreen(
                    memorialId: m.idMemorial,
                  ),
                ),
              ).then((_) {
                // Recargar la lista cuando regrese
                provider.cargarMisMemoriales(force: true);
              });
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
      return Center(child: Text("Error: ${provider.errorColab}"));
    }
    if (provider.colaborativos.isEmpty) {
      return const Center(child: Text("No tienes colaboraciones aún"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Forzar recarga completa
        await provider.cargarColaborativos(force: true);
      },
      color: const Color(0xFF6366F1), // Color del spinner
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.colaborativos.length,
        itemBuilder: (context, index) {
          final m = provider.colaborativos[index];
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
                  builder: (_) => MemorialDetailScreen(
                    memorialId: m.idMemorial,
                  ),
                ),
              ).then((_) {
                // Recargar la lista cuando regrese
                provider.cargarColaborativos(force: true);
              });
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
