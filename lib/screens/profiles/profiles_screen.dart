import 'package:flutter/material.dart';
import '../../components/components.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButtonCustom(icon: Icons.add, onPressed: () {}),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          indicator: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(25),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Mis Perfiles'),
            Tab(text: 'Colaboro'),
            Tab(text: 'Seguidos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyProfilesTab(),
          _buildCollaborationTab(),
          _buildFollowedTab(),
        ],
      ),
    );
  }

  Widget _buildMyProfilesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileCard(
          name: 'Ramiro Perez',
          description:
              'Ramiro tenía el don de hacer sentir especial a cada persona. Su humor y carisma unieron a la familia en los momentos más difíciles.',
          hasHeart: true,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProfileCard(
          name: 'Cecilio Nieto',
          description:
              'Cecilio dejó huellas imborrables con su bondad. Su generosidad no conocía límites y siempre encontró la manera de ayudar a los demás.',
          hasHeart: true,
          onTap: () {},
        ),
      ],
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

  Widget _buildFollowedTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay perfiles seguidos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
