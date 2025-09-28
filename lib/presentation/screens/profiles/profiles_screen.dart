import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial/relation_memorial_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import '../../components/components.dart';
import '../../components/navigation/tab_bar.dart';
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
    final provider = context.watch<MemorialProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Perfiles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
          bottom: Tab_Bar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Mis Perfiles'),
              Tab(text: 'Colaboraciones')
            ],
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMisMemoriales(provider),
          _buildCollaborationTab()
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

    return ListView.builder(
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
                  name: m.name,
                  description: m.description,
                  coverUrl: null,
                  avatarUrl: m.profilePhotoBase64,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollaborationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileCard(
          name: 'Lupita Montoya',
          description:
              'Lourdes fue el lazo de nuestras memorias más felices. Con su dulzura, transformó cada momento en algo especial.',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProfileCard(
          name: 'Lila De la Cruz',
          description: '',
          onTap: () {},
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
