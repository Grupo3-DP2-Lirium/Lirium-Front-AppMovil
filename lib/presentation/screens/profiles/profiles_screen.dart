import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/memorial/memorial_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial/relation_memorial_screen.dart';
import '../../components/components.dart';
import '../../components/navigation/tab_bar.dart';

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
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
          _buildMyProfilesTab(),
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
          isFullWidth: true, // ocupa todo el ancho disponible
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

  Widget _buildMyProfilesTab() {
    // Lista de memoriales falsos
    final fakeMemorials = List.generate(13, (index) {
      return {
        "name": "Memorial ${index + 1}",
        "description":
        "Este es un memorial de prueba número ${index + 1}. Aquí iría la descripción.",
      };
    });

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: fakeMemorials.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final m = fakeMemorials[index];
        return ProfileCard(
          name: m["name"]!,
          description: m["description"]!,
          hasHeart: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemorialDetailScreen(
                  memorialId: 'memorial-${index + 1}', // TODO: usa el real
                  name: m["name"]!,
                  description: m["description"]!,
                  coverUrl: null,      // o una URL si tienes
                  avatarUrl: null,     // o una URL si tienes
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
          showRegisterButton: true,
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
