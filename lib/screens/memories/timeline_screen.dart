import 'package:flutter/material.dart';
import 'memory_detail_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Línea de tiempo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todos', true),
                const SizedBox(width: 12),
                _buildFilterChip('Familia', false),
                const SizedBox(width: 12),
                _buildFilterChip('Amigos', false),
                const SizedBox(width: 12),
                _buildFilterChip('Eventos', false),
              ],
            ),
          ),
          // Timeline content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTimelineItem(
                  date: 'Hoy',
                  memories: [
                    {
                      'title': 'Almuerzo familiar',
                      'time': '2:30 PM',
                      'images': 4,
                      'description': 'Una tarde especial con la familia',
                    },
                  ],
                  context: context,
                ),
                _buildTimelineItem(
                  date: 'Ayer',
                  memories: [
                    {
                      'title': 'Cumpleaños de mamá',
                      'time': '7:00 PM',
                      'images': 8,
                      'description': 'Celebrando los 65 años de mamá',
                    },
                  ],
                  context: context,
                ),
                _buildTimelineItem(
                  date: '15 Dic 2024',
                  memories: [
                    {
                      'title': 'Paseo en el parque',
                      'time': '4:15 PM',
                      'images': 6,
                      'description': 'Tarde de domingo en familia',
                    },
                  ],
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6366F1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required List<Map<String, dynamic>> memories,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...memories.map((memory) => _buildMemoryCard(memory, context)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMemoryCard(Map<String, dynamic> memory, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemoryDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                Expanded(
                  child: Text(
                    memory['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  memory['time'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memory['description'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            // Photo grid placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      size: 40,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${memory['images']} fotos',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
