import 'package:flutter/material.dart';

class CollaboratorsScreen extends StatefulWidget {
  const CollaboratorsScreen({super.key});

  @override
  State<CollaboratorsScreen> createState() => _CollaboratorsScreenState();
}

class _CollaboratorsScreenState extends State<CollaboratorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Start on Colaboro tab
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
    return const Center(
      child: Text('Mis Perfiles'),
    );
  }

  Widget _buildCollaborationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCollaboratorCard(
          name: 'Ramiro Perez',
          description: 'Ramiro tenía el don de hacer sentir especial a cada persona. Su humor y carisma unieron a la familia en los momentos más difíciles. Para sus amigos, fue lealtad; para su familia, fue cariño eterno.',
          status: 'Colaborador',
          imageUrl: null,
        ),
        const SizedBox(height: 16),
        _buildCollaboratorCard(
          name: 'Cecilio Nieto',
          description: 'Cecilio dejó huellas imborrables con su bondad. Su generosidad no conocía límites y siempre encontró la manera de ayudar a los demás. Para sus hijos, fue protector; para todos, un corazón abierto.',
          status: 'Colaborador',
          imageUrl: null,
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
            'No hay necesidad de\nseguir a los\ncolaboradores, por ello\nes que no veo necesaria\nesta pantalla. No es una\nred social. En este caso,\nno sigues para ver quién\ntiene "mejor\ncontenido".',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorCard({
    required String name,
    required String description,
    required String status,
    String? imageUrl,
  }) {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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