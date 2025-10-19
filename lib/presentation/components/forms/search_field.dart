import 'package:flutter/material.dart';

// Search bar
class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const AppSearchBar({
    super.key,
    this.hintText = 'Buscar recuerdos...',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
