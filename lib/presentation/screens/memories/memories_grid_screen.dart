import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/forms/search_field.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/create_memory_to_memorial.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_detail_screen.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import '../../components/components.dart';
import 'package:provider/provider.dart';

class MemoriesGridScreen extends StatefulWidget {
  final Memory? newMemory;
  const MemoriesGridScreen({Key? key, this.newMemory}) : super(key: key);

  @override
  State<MemoriesGridScreen> createState() => _MemoriesGridScreenState();
}

class _MemoriesGridScreenState extends State<MemoriesGridScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prov = context.read<MemoryProvider>();
      prov.cargarMisMemorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemoryProvider>();
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    final memoriesToShow = prov.memoriasFiltradas.isNotEmpty || prov.textoBusqueda.isNotEmpty
        ? prov.memoriasFiltradas
        : prov.misMemorias;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Recuerdos",
        appBarHeight: appBarHeight,
        onBack: () {},
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Recargar las memorias forzando la actualización
          await prov.cargarMisMemorias(force: true);
        },
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppSearchBar(
                hintText: 'Buscar recuerdos...',
                onChanged: (text) {
                  prov.filtrarMemorias(text);
                },
              ),
            ),

            // Grid memories
            Expanded(
              child: prov.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : prov.error != null
                  ? Center(child: Text('Error: ${prov.error}'))
                  : memoriesToShow.isEmpty
                  ? const Center(child: Text('No memories found'))
                  : _buildGridView(memoriesToShow),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final createdMemory = await Navigator.push<Memory>(
            context,
            MaterialPageRoute(builder: (_) => CreateMemoryToMemorial()),
          );

          if (createdMemory != null) {
            prov.agregarMemoria(createdMemory);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemoryDetailScreen(memory: memory),
              ),
            );
            
            final prov = context.read<MemoryProvider>();

            if (result is Memory) {
              print('📝 Memoria actualizada');
              prov.actualizarMemoria(index, result);
            }
          },
        );
      },
    );
  }
}
