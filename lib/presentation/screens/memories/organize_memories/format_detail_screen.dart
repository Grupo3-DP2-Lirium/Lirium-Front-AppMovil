import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';

// Typedef para compatibilidad
typedef MemorialResponse = MemorialResponseModel;

class FormatDetailScreen extends StatefulWidget {
  final MemorialResponse memorial;
  final String formatType;
  final String formatTitle;
  final Color formatColor;
  final IconData formatIcon;

  const FormatDetailScreen({
    Key? key,
    required this.memorial,
    required this.formatType,
    required this.formatTitle,
    required this.formatColor,
    required this.formatIcon,
  }) : super(key: key);

  @override
  State<FormatDetailScreen> createState() => _FormatDetailScreenState();
}

class _FormatDetailScreenState extends State<FormatDetailScreen> {
  final MemoryService _memoryService = MemoryService();
  
  bool _isLoading = false;
  List<MemoryResponse> _memories = [];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _memoryService.getMemoriesOrganized(
        memorialId: widget.memorial.idMemorial,
        filterType: widget.formatType,
      );
      
      setState(() {
        _memories = response.memories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recuerdos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.formatTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header con información del memorial
          _buildMemorialHeader(),
          
          // Botones de acción
          _buildActionButtons(),
          
          // Información del formato
          _buildFormatInfo(),
          
          // Grid de recuerdos
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildMemoriesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemorialHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Foto de perfil
          CircleAvatar(
            radius: 30,
            backgroundImage: widget.memorial.profilePhoto?.fileUrl != null
                ? NetworkImage(widget.memorial.profilePhoto!.fileUrl)
                : null,
            child: widget.memorial.profilePhoto?.fileUrl == null
                ? Text(
                    widget.memorial.name.isNotEmpty 
                        ? widget.memorial.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Información del memorial
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memorial.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Última actualización hace 2 días',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar seguir
              },
              icon: const Icon(Icons.favorite_border, size: 18),
              label: const Text('0 seguidores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar compartir
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Compartir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.formatColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.formatIcon,
              color: widget.formatColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.formatTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_memories.length} elemento${_memories.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesGrid() {
    if (_memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.formatIcon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ${widget.formatTitle.toLowerCase()} para mostrar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        final memory = _memories[index];
        final hasImage = memory.files.isNotEmpty && memory.files.first.isImage;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasImage
                ? Image.network(
                    memory.files.first.downloadUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(memory);
                    },
                  )
                : _buildPlaceholder(memory),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(MemoryResponse memory) {
    return Container(
      color: widget.formatColor.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.formatIcon,
            size: 40,
            color: widget.formatColor,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              memory.title.isNotEmpty ? memory.title : 'Sin título',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.formatColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}