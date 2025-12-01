import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/forms/search_field.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/create_memory_to_memorial.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_detail_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/providers/memory_provider.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import '../../components/components.dart';
import 'package:provider/provider.dart';

class MemoriesGridScreen extends StatefulWidget {
  final Memory? newMemory;
  const MemoriesGridScreen({Key? key, this.newMemory}) : super(key: key);

  @override
  State<MemoriesGridScreen> createState() => _MemoriesGridScreenState();
}

class _MemoriesGridScreenState extends State<MemoriesGridScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Carga inicial
    Future.microtask(() {
      final prov = context.read<MemoryProvider>();
      prov.cargarMisMemorias();
    });
  }

  void _onScroll() {
    final prov = context.read<MemoryProvider>();

    // Si estamos a 200px del final y no se está cargando nada
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !prov.cargando) {
      prov.cargarMisMemorias(); // carga la siguiente página
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemoryProvider>();
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    final memoriesToShow = prov.memoriasFiltradas.isNotEmpty || prov.textoBusqueda.isNotEmpty
        ? prov.memoriasFiltradas
        : prov.misMemorias;

    Widget _buildEmptyState() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aún no tienes recuerdos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Crea un recuerdo para revivir un momento especial',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Crear mi primer recuerdo',
                icon: Icons.add,
                onPressed: () async {
                  final subProvider = context.read<SubscriptionProvider>();
                  final hasPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

                  if (hasPermission) {
                    final createdMemory = await Navigator.push<Memory>(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateMemoryToMemorial()),
                    );

                    if (createdMemory != null) {
                      final prov = context.read<MemoryProvider>();
                      prov.agregarMemoria(createdMemory);
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
                    ).then((_) async {
                      await subProvider.refreshPlan();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

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
                  _scrollController.jumpTo(0);
                },
              ),
            ),

            // Grid memories
            Expanded(
              child: prov.cargando && prov.misMemorias.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
                  : memoriesToShow.isEmpty
                  ? _buildEmptyState()
                  : NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!prov.cargando &&
                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                    prov.cargarMisMemorias();
                  }
                  return false;
                },
                child: _buildGridView(memoriesToShow, prov),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: memoriesToShow.isNotEmpty
          ? Builder(
        builder: (context) {
          final subProvider = context.watch<SubscriptionProvider>();
          final hasPermission = subProvider.permissions.contains("CREATE_MEMORIALS");

          return FloatingActionButton.extended(
            onPressed: hasPermission
                ? () async {
              final createdMemory = await Navigator.push<Memory>(
                context,
                MaterialPageRoute(builder: (_) => const CreateMemoryToMemorial()),
              );

              if (createdMemory != null) {
                final prov = context.read<MemoryProvider>();
                prov.agregarMemoria(createdMemory);
              }
            }
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GetPremiumScreen()),
              ).then((_) async {
                await subProvider.refreshPlan();
                setState(() {});
              });
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Crear Recuerdo',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primary.withOpacity(hasPermission ? 1.0 : 0.6),
          );
        },
      )
          : null,
    );
  }

  Widget _buildGridView(List<Memory> memories, MemoryProvider prov) {
    return GridView.builder(
      controller: _scrollController, // importante para scroll infinito
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: memories.length + (prov.cargando ? 1 : 0), // si está cargando, muestra loader
      itemBuilder: (context, index) {
        if (index < memories.length) {
          final memory = memories[index];
          return MemoryCard(
            memory: memory,
            isGridView: true,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MemoryDetailScreen(memory: memory)),
              );
              if (result is Memory) {
                prov.actualizarMemoria(index, result);
              }
            },
          );
        } else {
          // Loader final mientras carga más
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
