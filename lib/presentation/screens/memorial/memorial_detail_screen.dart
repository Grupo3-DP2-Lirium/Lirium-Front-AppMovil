import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/screens/memorial/collaborators_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/visualize_memories_screen.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/file_response.dart';
import '../../../data/services/memory_service.dart';
import '../../../data/models/memory_response.dart';

// Modos de organización de galería (HU19)
enum OrganizationMode { formato, lineaDeTiempo, tematicas, momentos }

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
  final MemoryService _memoriesService = MemoryService();
  
  // Estado para las memorias
  List<MemoryResponse> memories = [];
  bool isLoadingMemories = true;
  String? errorMessage;
  int currentPage = 0;
  final int pageSize = 10;
  bool hasMoreMemories = true;

  // Organización de galería (HU19)
  OrganizationMode _organizationMode = OrganizationMode.formato;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadMemories();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  int selectedTab = 0;

  ImageProvider _getAvatarImage() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      // Verificar si es una imagen en base64
      if (widget.avatarUrl!.startsWith('data:image') || widget.avatarUrl!.length > 500) {
        try {
          // Si empieza con data:image, extraer solo la parte base64
          final base64String = widget.avatarUrl!.contains(',') 
              ? widget.avatarUrl!.split(',').last 
              : widget.avatarUrl!;
          return MemoryImage(base64Decode(base64String));
        } catch (e) {
          print('Error decoding base64 image: $e');
          return const AssetImage('assets/images/CreaPerfil.png');
        }
      } else {
        // Es una URL normal
        return NetworkImage(widget.avatarUrl!);
      }
    } else {
      // Usar imagen por defecto
      return const AssetImage('assets/images/CreaPerfil.png');
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

  /// Carga las memorias del memorial desde el backend
  Future<void> _loadMemories() async {
    try {
      setState(() {
        isLoadingMemories = true;
        errorMessage = null;
      });

      final response = await _memoriesService.listMemories(
        memorialId: widget.memorialId,
        page: currentPage,
        size: pageSize,
      );
      
      setState(() {
        if (currentPage == 0) {
          memories = response.content;
        } else {
          memories.addAll(response.content);
        }
        hasMoreMemories = (response.number + 1) < response.totalPages;
        isLoadingMemories = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar las memorias: $e';
        isLoadingMemories = false;
      });
    }
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
                              onPressed: () {
                                // Navegar a la pantalla de visualizar recuerdos
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VisualizeMemoriesScreen(
                                      memorial: MemorialResponseModel(
                                        idMemorial: widget.memorialId,
                                        name: widget.name,
                                        nickname: '',
                                        description: widget.description ?? '',
                                        gender: '',
                                        relation: '',
                                        birthDate: '',
                                        isCollaborative: true,
                                        isJournal: false,
                                        userId: '',
                                        createdDate: DateTime.now(),
                                        updatedDate: DateTime.now(),
                                        profilePhoto: widget.avatarUrl != null 
                                            ? FileResponse(
                                                idFile: '',
                                                fileName: 'profile.jpg',
                                                originalFileName: 'profile.jpg',
                                                fileType: 'image',
                                                mimeType: 'image/jpeg',
                                                fileUrl: widget.avatarUrl!,
                                                fileSize: 0.0,
                                                uploadedDate: DateTime.now(),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 300, // Dar altura específica
        child: Column(
          children: [
          if (isLoadingMemories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        currentPage = 0;
                        _loadMemories();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (memories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay memorias para mostrar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: memories.length,
                itemBuilder: (context, index) {
                  final memory = memories[index];
                  return _buildMemoryPost(memory);
                },
              ),
            ),
        ],
        ),
      ),
    );
  }

  /// Construye un post de memoria estilo Instagram
  Widget _buildMemoryPost(MemoryResponse memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post con información del usuario
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(memory.createdDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          // Contenido de la memoria
          if (memory.files.isNotEmpty && memory.files.first.isImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(
                  memory.files.first.downloadUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Botones de interacción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.grey[700]),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: Colors.grey[700]),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, color: Colors.grey[700]),
                const Spacer(),
                if (memory.location != null)
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 16, color: Colors.grey[600]),
                      Text(
                        memory.location!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Descripción
          if (memory.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                memory.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          
          // Tags
          if (memory.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 4,
                children: memory.tags.map((tag) => Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// Formatea la fecha para mostrar en el post
  String _formatDate(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Ahora';
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
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

  // Tab 2: Organizar (HU19)
  Widget _buildOrganizeTab() {
    // Selector de modo de organización
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOrgChip('Formato', OrganizationMode.formato),
                const SizedBox(width: 8),
                _buildOrgChip('Línea de tiempo', OrganizationMode.lineaDeTiempo),
                const SizedBox(width: 8),
                _buildOrgChip('Temáticas', OrganizationMode.tematicas),
                const SizedBox(width: 8),
                _buildOrgChip('Momentos', OrganizationMode.momentos),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isLoadingMemories)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (errorMessage != null)
            Text(errorMessage!, style: TextStyle(color: Colors.red[600]))
          else if (memories.isEmpty)
            const Text('No hay memorias para organizar')
          else
            Expanded(child: _buildOrganizedList())
        ],
      ),
    );
  }

  Widget _buildOrgChip(String label, OrganizationMode mode) {
    final selected = _organizationMode == mode;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _organizationMode = mode),
    );
  }

  Widget _buildOrganizedList() {
    // Construir estructura según modo
    final Map<String, List<MemoryResponse>> groups = _groupMemories();
    final groupKeys = groups.keys.toList();

    return ListView.builder(
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final key = groupKeys[index];
        final items = groups[key] ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[i];
                final url = m.firstImageUrl ?? 'https://via.placeholder.com/300x300.png?text=Memoria';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(url, fit: BoxFit.cover),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Map<String, List<MemoryResponse>> _groupMemories() {
    switch (_organizationMode) {
      case OrganizationMode.formato:
        return _groupBy(memories, (m) => _formatFromMemory(m));
      case OrganizationMode.lineaDeTiempo:
        // Agrupar por año-mes
        return _groupBy(memories, (m) {
          final d = m.photoDate ?? m.createdDate;
          return '${d.year}-${d.month.toString().padLeft(2, '0')}';
        }, sortByKey: true, keyComparator: (a, b) => b.compareTo(a));
      case OrganizationMode.tematicas:
        // Para cada etiqueta crear grupos; si no hay, va a 'Sin etiqueta'
        final Map<String, List<MemoryResponse>> g = {};
        for (final m in memories) {
          final tags = m.tags.isEmpty ? ['Sin etiqueta'] : m.tags;
          for (final t in tags) {
            g.putIfAbsent(t, () => []).add(m);
          }
        }
        return g;
      case OrganizationMode.momentos:
        return _groupBy(memories, (m) => m.associatedQuestion ?? (m.tags.isNotEmpty ? m.tags.first : 'General'));
    }
  }

  String _formatFromMemory(MemoryResponse m) {
    // Usar field type cuando esté disponible, si no, derivar del media
    final t = m.type.toLowerCase();
    if (t.isNotEmpty) return t;
    final types = m.mediaTypes;
    if (types.length == 1) {
      switch (types.first) {
        case 'image':
          return 'foto';
        case 'video':
          return 'video';
        case 'audio':
          return 'audio';
      }
    }
    return types.isEmpty ? 'texto' : 'mixto';
  }

  Map<String, List<MemoryResponse>> _groupBy<T>(
    List<MemoryResponse> list,
    String Function(MemoryResponse) keySelector, {
    bool sortByKey = false,
    int Function(String a, String b)? keyComparator,
  }) {
    final Map<String, List<MemoryResponse>> map = {};
    for (final item in list) {
      final k = keySelector(item);
      map.putIfAbsent(k, () => []).add(item);
    }
    if (sortByKey) {
      final entries = map.entries.toList()
        ..sort((a, b) => (keyComparator ?? (String a, String b) => a.compareTo(b))(a.key, b.key));
      return {for (final e in entries) e.key: e.value};
    }
    return map;
  }


}
