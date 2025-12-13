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
  String _selectedFilter = 'all'; // all, image, video, audio, letter

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

  List<Memory> _getFilteredMemories(List<Memory> memories) {
    if (_selectedFilter == 'all') return memories;

    return memories.where((memory) {
      switch (_selectedFilter) {
        case 'image':
          return memory.files.any((f) => f.type == 'image');
        case 'video':
          return memory.files.any((f) => f.type == 'video');
        case 'audio':
          return memory.files.any((f) => f.type == 'audio');
        case 'letter':
          final isLetter = memory.title.toLowerCase().contains('carta personal') ||
              (memory.files.isEmpty && memory.description.isNotEmpty);
          return isLetter;
        default:
          return true;
      }
    }).toList();
  }

  Map<String, int> _getFormatCounts(List<Memory> memories) {
    final counts = {
      'image': 0,
      'video': 0,
      'audio': 0,
      'letter': 0,
    };

    for (final memory in memories) {
      final isLetter = memory.title.toLowerCase().contains('carta personal') ||
          (memory.files.isEmpty && memory.description.isNotEmpty);

      if (isLetter) {
        counts['letter'] = counts['letter']! + 1;
      }

      for (final file in memory.files) {
        if (file.type == 'image' && counts['image'] != null) {
          counts['image'] = counts['image']! + 1;
          break;
        }
        if (file.type == 'video' && counts['video'] != null) {
          counts['video'] = counts['video']! + 1;
          break;
        }
        if (file.type == 'audio' && counts['audio'] != null) {
          counts['audio'] = counts['audio']! + 1;
          break;
        }
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemoryProvider>();
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    final memoriesToShow = prov.memoriasFiltradas.isNotEmpty || prov.textoBusqueda.isNotEmpty
        ? prov.memoriasFiltradas
        : prov.misMemorias;

    final filteredMemories = _getFilteredMemories(memoriesToShow);
    final formatCounts = _getFormatCounts(memoriesToShow);

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
              Text(
                _selectedFilter == 'all'
                    ? 'Aún no tienes recuerdos'
                    : 'No hay recuerdos de este tipo',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilter == 'all'
                    ? 'Crea un recuerdo para revivir un momento especial'
                    : 'Intenta con otro filtro',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedFilter == 'all') ...[
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

            // Chips de filtro por formato
            if (memoriesToShow.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Todos',
                      icon: Icons.grid_view_rounded,
                      value: 'all',
                      count: memoriesToShow.length,
                    ),
                    const SizedBox(width: 8),
                    if (formatCounts['image']! > 0)
                      _buildFilterChip(
                        label: 'Fotos',
                        icon: Icons.photo_library_rounded,
                        value: 'image',
                        count: formatCounts['image']!,
                      ),
                    if (formatCounts['image']! > 0) const SizedBox(width: 8),
                    if (formatCounts['video']! > 0)
                      _buildFilterChip(
                        label: 'Videos',
                        icon: Icons.videocam_rounded,
                        value: 'video',
                        count: formatCounts['video']!,
                      ),
                    if (formatCounts['video']! > 0) const SizedBox(width: 8),
                    if (formatCounts['audio']! > 0)
                      _buildFilterChip(
                        label: 'Audios',
                        icon: Icons.audiotrack_rounded,
                        value: 'audio',
                        count: formatCounts['audio']!,
                      ),
                    if (formatCounts['audio']! > 0) const SizedBox(width: 8),
                    if (formatCounts['letter']! > 0)
                      _buildFilterChip(
                        label: 'Texto',
                        icon: Icons.mail_rounded,
                        value: 'letter',
                        count: formatCounts['letter']!,
                      ),
                  ],
                ),
              ),

            if (memoriesToShow.isNotEmpty) const SizedBox(height: 16),

            // Grid memories
            Expanded(
              child: prov.cargando && prov.misMemorias.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
                  : filteredMemories.isEmpty
                  ? _buildEmptyState()
                  : NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!prov.cargando &&
                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                    prov.cargarMisMemorias();
                  }
                  return false;
                },
                child: _buildGridView(filteredMemories, prov),
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

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required String value,
    required int count,
  }) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 0 : 1,
        ),
      ),
    );
  }

  Widget _buildGridView(List<Memory> memories, MemoryProvider prov) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: memories.length + (prov.cargando ? 1 : 0),
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