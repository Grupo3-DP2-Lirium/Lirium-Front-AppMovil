import 'package:flutter/material.dart';

class FeedWithFeedbackScreen extends StatelessWidget {
  const FeedWithFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Hola, Fer!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Mantente cerca de quienes recuerdas',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Stories section
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStoryItem('Lupita Montoya', null),
                    _buildStoryItem('Pedro Suarez', null),
                    _buildStoryItem('Anita Vega', null),
                    _buildStoryItem('Luis', null),
                  ],
                ),
              ),      
        const Divider(height: 1),
              // Feed section
              Expanded(
                child: ListView(
                  children: [
                    _buildFeedPost(
                      userName: 'Pedro Vertiz',
                      timeAgo: 'Hace 2 horas',
                      content: 'Se agregó en "Línea de Tiempo"\nTener, ver nosotros y bailar vals',
                      images: [
                        'image1', 'image2', 'image3', 'image4', 'image5', 'image6'
                      ],
                      likes: 0,
                      comments: 0,
                    ),
                    _buildFeedPost(
                      userName: 'Margarita Suarez',
                      timeAgo: 'Hace 5 horas',
                      content: 'Compartió nuevos recuerdos familiares',
                      images: [],
                      likes: 2,
                      comments: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Feedback overlay
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Queda, retrata bien lo que queremos hacer.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Perfiles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Memorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String name, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6366F1),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, color: Colors.grey, size: 24)
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              name.split(' ').first,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedPost({
    required String userName,
    required String timeAgo,
    required String content,
    required List<String> images,
    required int likes,
    required int comments,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Image grid
            Container(
              height: 200,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: images.length > 6 ? 6 : images.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Icon(
                likes > 0 ? Icons.favorite : Icons.favorite_border,
                color: likes > 0 ? Colors.red : Colors.grey,
                size: 20,
              ),
              if (likes > 0) ...[
                const SizedBox(width: 4),
                Text(
                  likes.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(width: 16),
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey,
                size: 20,
              ),
              if (comments > 0) ...[
                const SizedBox(width: 4),
                Text(
                  comments.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}