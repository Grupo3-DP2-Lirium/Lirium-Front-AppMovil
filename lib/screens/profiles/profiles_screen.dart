import 'package:flutter/material.dart';
import 'profile_detail_view_screen.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> with SingleTickerProviderStateMixin {
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
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
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
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 16),
                  SizedBox(width: 4),
                  Text('Mis Perfiles'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 16),
                  SizedBox(width: 4),
                  Text('Colaboro'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, size: 16),
                  SizedBox(width: 4),
                  Text('Seguidos'),
                ],
              ),
            ),
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
        _buildProfileCard(
          name: 'Ramiro Perez',
          description: 'Ramiro tenía el don de hacer sentir especial a cada persona. Su humor y carisma unieron a la familia en los momentos más difíciles. Para sus amigos, fue lealidad; para su familia, fue cariño eterno.',
          imageUrl: null,
          hasHeart: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileDetailViewScreen(
                  profileName: 'Ramiro Perez',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildProfileCard(
          name: 'Cecilio Nieto',
          description: 'Cecilio dejó huellas imborrables con su bondad. Su generosidad no conocía límites y siempre encontró la manera de ayudar a los demás. Para sus hijos, fue protector; para todos, un corazón abierto.',
          imageUrl: null,
          hasHeart: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileDetailViewScreen(
                  profileName: 'Cecilio Nieto',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollaborationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(
          name: 'Lupita Montoya',
          description: 'Lourdes fue el lazo de nuestras memorias más felices. Con su dulzura, transformó cada momento en algo especial. Para sus tres nietos, fue gracia, refugio y ejemplo de amor incondicional.',
          imageUrl: null,
          hasHeart: false,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _buildProfileCard(
          name: 'Margarita Vera',
          description: 'Margarita llenó nuestras vidas de luz con su risa contagiosa. Siempre tenía una palabra de aliento y un gesto de ternura. Para sus amigos y sobrinos, fue ese abrazo que siempre nos daba fuerzas que arriba a seguir adelante.',
          imageUrl: null,
          hasHeart: false,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _buildProfileCard(
          name: 'Luis Ramirez',
          description: 'Luis fue su sostén y la calma en medio de las tormentas. Su paciencia y sabiduría marcaron el camino de quienes lo rodeaban. Para sus nietos, fue maestro de vida y modelo de integridad.',
          imageUrl: null,
          hasHeart: false,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _buildProfileCard(
          name: 'Lila De la Cruz',
          description: '',
          imageUrl: null,
          hasHeart: false,
          onTap: () {},
          showRegisterButton: true,
        ),
      ],
    );
  }

  Widget _buildFollowedTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No hay perfiles seguidos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Los perfiles que sigas aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String description,
    String? imageUrl,
    required bool hasHeart,
    required VoidCallback onTap,
    bool showRegisterButton = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (hasHeart)
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, color: Colors.grey, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (showRegisterButton) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Registrarse para comentar',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}