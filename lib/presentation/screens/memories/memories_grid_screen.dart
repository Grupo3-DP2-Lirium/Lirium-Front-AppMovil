import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/forms/search_field.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/create_memory_to_memorial.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_detail_screen.dart';
import '../../components/components.dart';
import '../main/main_navigation_screen.dart';

// Screen that displays the list of memories
class MemoriesGridScreen extends StatefulWidget {
  const MemoriesGridScreen({super.key});

  @override
  State<MemoriesGridScreen> createState() => _MemoriesGridScreenState();
}

class _MemoriesGridScreenState extends State<MemoriesGridScreen> {
  bool isGridView = true;
  final _service = MemoryService();
  late Future<List<Memory>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listMemoriesByAuthor();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Recuerdos",
        appBarHeight: appBarHeight,
        onBack: () {
        },
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    hintText: 'Buscar recuerdos...',
                    onChanged: (text) {
                    },
                  ),
                ),
              ],
            ),
          ),
          // List of Memories (Grid)
          Expanded(
            child: FutureBuilder<List<Memory>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No memories found'));
                }
                final memories = snapshot.data!;
                return _buildGridView(memories);
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateMemoryToMemorial()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // GridView
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
          memory: memory,
          isGridView: true,
          onTap: () async {
            final updatedMemory = await Navigator.push<Memory>(
              context,
              MaterialPageRoute(
                builder: (_) => MemoryDetailScreen(memory: memory),
              ),
            );
            if (updatedMemory != null) {
              setState(() {
                memories[index] = updatedMemory;
              });
            }
          },
        );
      },
    );
  }
}