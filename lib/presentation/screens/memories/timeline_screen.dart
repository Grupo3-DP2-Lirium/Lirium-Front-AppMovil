import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/components.dart';
import '../../../data/models/memorial_response.dart';
import '../../../data/models/memory_response.dart';
import '../../../data/services/memory_service.dart';

// Typedef para compatibilidad
typedef MemorialResponse = MemorialResponseModel;

class TimelineScreen extends StatefulWidget {
  final MemorialResponse memorial;

  const TimelineScreen({
    super.key,
    required this.memorial,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final MemoryService _memoryService = MemoryService();
  
  bool _isLoading = false;
  List<MemoryResponse> _memories = [];
  String _selectedFilter = 'all';
  Map<String, List<MemoryResponse>> _memoriesByDate = {};

  final List<Map<String, String>> _filterOptions = [
    {'key': 'all', 'label': 'Todos'},
    {'key': 'familia', 'label': 'Familia'},
    {'key': 'amigos', 'label': 'Amigos'},
    {'key': 'eventos', 'label': 'Eventos'},
    {'key': 'viajes', 'label': 'Viajes'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _memoryService.getMemoriesByTimeline(
        memorialId: widget.memorial.idMemorial,
      );
      
      // Procesar la respuesta del timeline
      _processTimelineResponse(response);
      
    } catch (e) {
      print('Error loading timeline memories: $e');
      // Fallback: cargar todas las memorias y organizarlas localmente
      await _loadAllMemoriesAsFallback();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllMemoriesAsFallback() async {
    try {
      final response = await _memoryService.getMemoriesOrganized(
        memorialId: widget.memorial.idMemorial,
        filterType: 'all',
        sortBy: 'date',
        sortOrder: 'desc',
      );
      
      setState(() {
        _memories = response.memories;
        _organizeMemoriesByDate();
      });
    } catch (e) {
      print('Error loading fallback memories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recuerdos: $e')),
      );
    }
  }

  void _processTimelineResponse(Map<String, dynamic> response) {
    // Procesar la respuesta del backend que viene agrupada por año/mes
    List<MemoryResponse> allMemories = [];
    
    if (response['memoriesByTimeline'] != null) {
      final memoriesByTimeline = response['memoriesByTimeline'] as Map<String, dynamic>;
      
      memoriesByTimeline.forEach((year, monthsData) {
        if (monthsData is Map<String, dynamic>) {
          monthsData.forEach((month, memoriesData) {
            if (memoriesData is List) {
              for (var memoryData in memoriesData) {
                allMemories.add(MemoryResponse.fromJson(memoryData));
              }
            }
          });
        }
      });
    }
    
    setState(() {
      _memories = allMemories;
      _organizeMemoriesByDate();
    });
  }

  void _organizeMemoriesByDate() {
    _memoriesByDate.clear();
    
    // Filtrar memorias según el filtro seleccionado
    List<MemoryResponse> filteredMemories = _filterMemories(_memories);
    
    // Agrupar por fecha
    for (final memory in filteredMemories) {
      final date = memory.photoDate ?? memory.createdDate;
      final dateKey = _getDateKey(date);
      
      _memoriesByDate.putIfAbsent(dateKey, () => []).add(memory);
    }
    
    // Ordenar las memorias dentro de cada fecha por hora
    _memoriesByDate.forEach((date, memories) {
      memories.sort((a, b) {
        final dateA = a.photoDate ?? a.createdDate;
        final dateB = b.photoDate ?? b.createdDate;
        return dateB.compareTo(dateA); // Más reciente primero
      });
    });
  }

  List<MemoryResponse> _filterMemories(List<MemoryResponse> memories) {
    if (_selectedFilter == 'all') return memories;
    
    return memories.where((memory) {
      final tags = memory.tags.map((tag) => tag.toLowerCase()).toList();
      final title = memory.title.toLowerCase();
      final description = memory.description.toLowerCase();
      
      switch (_selectedFilter) {
        case 'familia':
          return tags.any((tag) => tag.contains('familia')) ||
                 title.contains('familia') ||
                 description.contains('familia');
        case 'amigos':
          return tags.any((tag) => tag.contains('amigos') || tag.contains('amigo')) ||
                 title.contains('amigos') ||
                 description.contains('amigos');
        case 'eventos':
          return tags.any((tag) => tag.contains('evento') || tag.contains('celebración') || tag.contains('cumpleaños')) ||
                 title.contains('evento') ||
                 description.contains('evento');
        case 'viajes':
          return tags.any((tag) => tag.contains('viaje') || tag.contains('vacaciones')) ||
                 title.contains('viaje') ||
                 description.contains('viaje');
        default:
          return true;
      }
    }).toList();
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final memoryDate = DateTime(date.year, date.month, date.day);
    
    if (memoryDate == today) {
      return 'Hoy';
    } else if (memoryDate == yesterday) {
      return 'Ayer';
    } else if (now.difference(memoryDate).inDays < 7) {
      return DateFormat('EEEE', 'es').format(date); // Día de la semana
    } else if (date.year == now.year) {
      return DateFormat('d MMMM', 'es').format(date); // Día y mes
    } else {
      return DateFormat('d MMMM yyyy', 'es').format(date); // Fecha completa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarCustom(
        title: 'Línea de tiempo',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Implementar menú
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option['key'];
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: AppFilterChip(
                    label: option['label']!,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedFilter = option['key']!;
                        _organizeMemoriesByDate();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Timeline content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildTimelineContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a crear memoria
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimelineContent() {
    if (_memoriesByDate.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay recuerdos para mostrar',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Ordenar las fechas (más reciente primero)
    final sortedDates = _memoriesByDate.keys.toList()..sort((a, b) {
      // Ordenar por prioridad: Hoy, Ayer, luego por fecha
      if (a == 'Hoy') return -1;
      if (b == 'Hoy') return 1;
      if (a == 'Ayer') return -1;
      if (b == 'Ayer') return 1;
      return b.compareTo(a);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final memories = _memoriesByDate[date]!;
        
        return _buildTimelineSection(date, memories);
      },
    );
  }

  Widget _buildTimelineSection(String date, List<MemoryResponse> memories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la fecha
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${memories.length} recuerdo${memories.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Lista de memorias del día
        ...memories.map((memory) => _buildMemoryTimelineItem(memory)).toList(),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMemoryTimelineItem(MemoryResponse memory) {
    final hasImages = memory.files.any((file) => file.isImage);
    final imageFiles = memory.files.where((file) => file.isImage).toList();
    final memoryDate = memory.photoDate ?? memory.createdDate;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y hora
          Row(
            children: [
              Expanded(
                child: Text(
                  memory.title.isNotEmpty ? memory.title : 'Sin título',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                DateFormat('HH:mm').format(memoryDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          if (memory.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              memory.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Imágenes
          if (hasImages) ...[
            const SizedBox(height: 12),
            _buildImageGrid(imageFiles),
          ],
          
          // Footer con información adicional
          const SizedBox(height: 12),
          Row(
            children: [
              if (memory.location != null && memory.location!.isNotEmpty) ...[
                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  memory.location!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Icon(Icons.photo_library, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${memory.files.length} archivo${memory.files.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<dynamic> imageFiles) {
    if (imageFiles.isEmpty) return const SizedBox.shrink();
    
    if (imageFiles.length == 1) {
      return _buildSingleImage(imageFiles.first);
    } else if (imageFiles.length == 2) {
      return _buildTwoImages(imageFiles);
    } else if (imageFiles.length == 3) {
      return _buildThreeImages(imageFiles);
    } else {
      return _buildMultipleImages(imageFiles);
    }
  }

  Widget _buildSingleImage(dynamic imageFile) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageFile.downloadUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              color: Colors.grey[300],
              child: Icon(Icons.photo, color: Colors.grey[500], size: 40),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTwoImages(List<dynamic> imageFiles) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageFiles[0].downloadUrl,
                fit: BoxFit.cover,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.photo, color: Colors.grey[500]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageFiles[1].downloadUrl,
                fit: BoxFit.cover,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.photo, color: Colors.grey[500]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeImages(List<dynamic> imageFiles) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageFiles[0].downloadUrl,
                fit: BoxFit.cover,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.photo, color: Colors.grey[500]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageFiles[1].downloadUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.photo, color: Colors.grey[500]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageFiles[2].downloadUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.photo, color: Colors.grey[500]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleImages(List<dynamic> imageFiles) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageFiles[0].downloadUrl,
                fit: BoxFit.cover,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.photo, color: Colors.grey[500]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageFiles[1].downloadUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.photo, color: Colors.grey[500]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageFiles[2].downloadUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.photo, color: Colors.grey[500]),
                            );
                          },
                        ),
                      ),
                      if (imageFiles.length > 3)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${imageFiles.length - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
