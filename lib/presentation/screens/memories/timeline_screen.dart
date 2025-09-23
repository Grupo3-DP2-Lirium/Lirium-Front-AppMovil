import 'package:flutter/material.dart';
import '../../components/components.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarCustom(
        title: 'Línea de tiempo',
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
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                AppFilterChip(label: 'Todos', isSelected: true, onTap: () {}),
                const SizedBox(width: 12),
                AppFilterChip(
                  label: 'Familia',
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                AppFilterChip(label: 'Amigos', isSelected: false, onTap: () {}),
                const SizedBox(width: 12),
                AppFilterChip(
                  label: 'Eventos',
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          // Timeline content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTimelineSection('Hoy', [
                  {
                    'title': 'Almuerzo familiar',
                    'time': '2:30 PM',
                    'images': 4,
                    'description': 'Una tarde especial con la familia',
                  },
                ]),
                _buildTimelineSection('Ayer', [
                  {
                    'title': 'Cumpleaños de mamá',
                    'time': '7:00 PM',
                    'images': 8,
                    'description': 'Celebrando los 65 años de mamá',
                  },
                ]),
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

  Widget _buildTimelineSection(
    String date,
    List<Map<String, dynamic>> memories,
  ) {
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
        ...memories.map(
          (memory) => MemoryCard(
            title: memory['title'],
            subtitle: memory['description'],
            time: memory['time'],
            imageCount: memory['images'],
            onTap: () {},
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
