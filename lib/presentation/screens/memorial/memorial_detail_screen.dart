import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/icon_button_custom.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborators_screen.dart';


class MemorialDetailScreen extends StatefulWidget {
  final String memorialId;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? avatarUrl;

  const MemorialDetailScreen({
    super.key,
    required this.memorialId,
    required this.name,
    this.description,
    this.coverUrl,
    this.avatarUrl,
  });

  @override
  State<MemorialDetailScreen> createState() => _MemorialDetailScreenState();
}

class _MemorialDetailScreenState extends State<MemorialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  int selectedTab = 0;

  ImageProvider _getAvatarImage() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return MemoryImage(base64Decode(widget.avatarUrl!));
    } else if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return NetworkImage(widget.avatarUrl!);
    } else {
      return const AssetImage("assets/images/default_avatar.png");
    }
  }

  ImageProvider _getCoverImage() {
    if (widget.coverUrl == null || widget.coverUrl!.isEmpty) {
      return const NetworkImage(
        'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
      );
    }

    if (widget.coverUrl!.startsWith('data:image')) {
      final base64Str = widget.coverUrl!.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }

    return NetworkImage(widget.coverUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getCoverImage(),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Settings Button
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),

          // Main Content
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Name
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Editado por 3 personas · Última actualización\nhace 2 días',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buttons Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                side: const BorderSide(color: Color(0xEDD99293)),
                              ),
                              child: const Text(
                                'Ver Memorial completo',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => CollaboratorsScreen(memorialId: widget.memorialId),
                                ));
                              },
                              icon: const Icon(Icons.people, size: 18, color: Color(0xFF6366F1)),
                              label: const Text('Colaboradores'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                side: const BorderSide(color: Color(0xFF6366F1)),
                                foregroundColor: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quote Card
                    if (widget.description != null && widget.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xEDD99293),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            widget.description!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildTab('Actividad reciente', 0),
                          const SizedBox(width: 8),
                          _buildTab('Añadir', 1),
                          const SizedBox(width: 8),
                          _buildTab('Organizar', 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content based on selected tab
                    if (selectedTab == 0) _buildActivityTab(),
                    if (selectedTab == 1) _buildTimelineTab(),
                    if (selectedTab == 2) _buildOrganizeTab(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Profile Picture
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: _getAvatarImage(),
                    fit: BoxFit.cover,
                  ),
                ),
                child: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFEBF0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFEBF0F0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Tab 0: Actividad reciente
  Widget _buildActivityTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Activity Section
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fer (Tú)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Compartió 7 fotos',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photo Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              _buildPhotoCard(
                'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400',
              ),
              Column(
                children: [
                  Expanded(
                    child: _buildPhotoCard(
                      'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildPhotoCard(
                      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
                    ),
                  ),
                ],
              ),
              _buildPhotoCard(
                'https://images.unsplash.com/photo-1571844307880-751c6d86f3f3?w=400',
              ),
              _buildPhotoCard(
                'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400',
              ),
              _buildPhotoCard(
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
              ),
              _buildPhotoCard(
                'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tab 1: Añadir (Timeline)
  Widget _buildTimelineTab() {
    final timelineEvents = [
      {
        'year': '1946',
        'title': 'Nació Lourdes',
        'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        'hasButton': false,
      },
      {
        'year': '1972',
        'title': 'Lourdes se convirtió en mamá',
        'image': 'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400',
        'hasButton': true,
      },
      {
        'year': '1984',
        'title': 'Primer viaje familiar',
        'image': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
        'hasButton': true,
      },
      {
        'year': '2002',
        'title': 'Nacimiento de su última nieta',
        'image': 'https://images.unsplash.com/photo-1571844307880-751c6d86f3f3?w=400',
        'hasButton': false,
      },
      {
        'year': '2016',
        'title': 'Cumpleaños N°70',
        'image': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
        'hasButton': false,
      },
      {
        'year': '2018',
        'title': 'Cumpleaños N°72',
        'image': 'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400',
        'hasButton': false,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: timelineEvents.map((event) {
          return _buildTimelineItem(
            year: event['year'] as String,
            title: event['title'] as String,
            imageUrl: event['image'] as String,
            hasButton: event['hasButton'] as bool,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String imageUrl,
    required bool hasButton,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 120,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (hasButton) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF6366F1),
                                ),
                                label: const Text(
                                  'Ver más',
                                  style: TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Organizar (Grid de todas las fotos)
  Widget _buildOrganizeTab() {
    final images = [
      'https://images.unsplash.com/photo-1571844307880-751c6d86f3f3?w=400',
      'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400',
      'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400',
      'https://images.unsplash.com/photo-1571844307880-751c6d86f3f3?w=400',
      'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Large featured image
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(images[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Grid of smaller images
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images.length - 1,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(images[index + 1]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
