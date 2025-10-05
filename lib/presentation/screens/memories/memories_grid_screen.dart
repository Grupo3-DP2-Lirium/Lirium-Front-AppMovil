import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memorial_service.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/file.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/create_memory_to_memorial.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_detail_screen.dart';
import '../../components/components.dart';

class MemoriesGridScreen extends StatefulWidget {
  const MemoriesGridScreen({super.key});

  @override
  State<MemoriesGridScreen> createState() => _MemoriesGridScreenState();
}

class _MemoriesGridScreenState extends State<MemoriesGridScreen> {
  bool isGridView = true;
  final _service = MemoryService();
  late Future<List<Memory>> _future;

  // Fake memories como fallback
  final List<Memory> fakeMemories = [
    // Pregunta & Respuesta
    Memory(
      id: "q1",
      title: "¿Cuál es tu color favorito?",
      description: "Azul",
      type: "question_answer",
      location: null,
      visible: true,
      tags: [],
      associatedQuestion: null,
      totalUsedSpace: 0,
      photoDate: null,
      files: [],
      createdDate: DateTime(2025),
    ),
    // Imagen
    Memory(
      id: "i1",
      title: "Recuerdo con foto",
      description: "Un día en la playa 🌊",
      type: "image",
      location: "Lima",
      visible: true,
      tags: [],
      associatedQuestion: null,
      totalUsedSpace: 0,
      photoDate: DateTime(2025, 5, 20),
      files: [
        File(
          id: "f1",
          name: "playa",
          originalName: "playa.jpg",
          type: "image",
          mimeType: "image/jpeg",
          url: "https://via.placeholder.com/300x200.png?text=Foto+Playa",
          size: 12345,
          uploadedDate: DateTime(2025, 5, 20),
        )
      ],
      createdDate: DateTime(2025),
    ),
    // Video
    Memory(
      id: "v1",
      title: "Recuerdo con video",
      description: "Concierto en vivo 🎶",
      type: "video",
      location: "Arequipa",
      visible: true,
      tags: [],
      associatedQuestion: null,
      totalUsedSpace: 0,
      photoDate: DateTime(2025, 6, 10),
      files: [
        File(
          id: "f2",
          name: "concierto",
          originalName: "concierto.mp4",
          type: "video",
          mimeType: "video/mp4",
          url: '',
          size: 54321,
          uploadedDate: DateTime(2025, 6, 10),
        )
      ],
      createdDate: DateTime(2025),
    ),
    // Audio
    Memory(
      id: "a1",
      title: "Recuerdo con audio",
      description: "Canción especial 🎵",
      type: "audio",
      location: "Cusco",
      visible: true,
      tags: [],
      associatedQuestion: null,
      totalUsedSpace: 0,
      photoDate: DateTime(2025, 7, 5),
      files: [
        File(
          id: "f3",
          name: "cancion",
          originalName: "cancion.mp3",
          type: "audio",
          mimeType: "audio/mpeg",
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
          size: 98765,
          uploadedDate: DateTime(2025, 7, 5),
        )
      ],
      createdDate: DateTime(2025),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Inicializamos el future con la llamada real
    _future = _service.listMemoriesByAuthor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Memorias',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Buscar recuerdos...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButtonCustom(icon: Icons.tune, onPressed: () {}),
              ],
            ),
          ),
          // Content
          Expanded(
            child: FutureBuilder<List<Memory>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Si hay error, usamos fakeMemories
                  return isGridView
                      ? _buildGridView(fakeMemories)
                      : _buildListView(fakeMemories);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Si no hay datos, usamos fakeMemories
                  return isGridView
                      ? _buildGridView(fakeMemories)
                      : _buildListView(fakeMemories);
                }

                final memories = snapshot.data!;
                return isGridView
                    ? _buildGridView(memories)
                    : _buildListView(memories);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateMemoryToMemorial()),
        ),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // GridView y ListView reciben la lista de memorias
  Widget _buildGridView(List<Memory> memories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return MemoryCard(
          title: memory.title,
          time: 'Hace ${index + 1} días',
          isGridView: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemoryDetailScreen(
                    memory: memory
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(List<Memory> memories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return MemoryCard(
          title: memory.title,
          subtitle: memory.description,
          time: 'Hace ${index + 1} días',
          onTap: () {},
        );
      },
    );
  }
}