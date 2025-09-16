import 'package:flutter/material.dart';

class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[300]!, Colors.grey[100]!],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.photo_camera, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and date
                  const Text(
                    'Almuerzo familiar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hoy, 2:30 PM',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Una tarde especial compartiendo en familia. Preparamos la comida favorita de la abuela y todos pudimos estar juntos después de mucho tiempo.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Photo grid
                  const Text(
                    'Fotos (4)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Participants
                  const Text(
                    'Participantes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildParticipant('Mamá', 'M'),
                      const SizedBox(width: 12),
                      _buildParticipant('Papá', 'P'),
                      const SizedBox(width: 12),
                      _buildParticipant('Ana', 'A'),
                      const SizedBox(width: 12),
                      _buildParticipant('Tú', 'T'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF6366F1),
                          ),
                          label: const Text(
                            'Editar',
                            style: TextStyle(color: Color(0xFF6366F1)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6366F1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add_comment,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Comentar',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipant(String name, String initial) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF6366F1),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
