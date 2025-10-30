import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';

class FormatTypeDetailScreen extends StatelessWidget {
  final String title;
  final List<MemoryResponse> memories;
  final Color color;

  const FormatTypeDetailScreen({
    Key? key,
    required this.title,
    required this.memories,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          // Botón Crear Recuerdo
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crear Recuerdo - Próximamente')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Crear Recuerdo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (title.toLowerCase() == 'fotos') {
      return _buildPhotosGrid();
    } else if (title.toLowerCase() == 'videos') {
      return _buildVideosList();
    } else if (title.toLowerCase() == 'audios') {
      return _buildAudiosList();
    } else {
      return _buildDocumentsList();
    }
  }

  Widget _buildPhotosGrid() {
    final photosWithImages = memories.where((m) => 
      m.files.isNotEmpty && m.files.any((f) => f.isImage)
    ).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: photosWithImages.length,
      itemBuilder: (context, index) {
        final memory = photosWithImages[index];
        final imageFile = memory.files.firstWhere((f) => f.isImage);
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageFile.downloadUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 32),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        final videoFile = memory.files.isNotEmpty ? memory.files.first : null;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_circle_outline, color: Colors.green, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(memory.createdDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudiosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(memory.createdDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Colors.orange, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(memory.createdDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}:${date.hour.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}';
  }
}
