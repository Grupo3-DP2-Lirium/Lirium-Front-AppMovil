import 'package:flutter/material.dart';
import 'memorial_data/memorial_data.dart';
class RowOfMemories extends StatelessWidget {
  final String tipo;
  const RowOfMemories({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final data = tipo == "memoriales" ? memoriales : compartidos;
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: data
          .map((item) => _buildMemorial(item["name"]!, item["url"]!))
          .toList(),
    );
  }

  Widget _buildMemorial(String name, String imageUrl) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
          SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }
}
