import 'package:flutter/material.dart';

class CustomMemoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  const CustomMemoryAppBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight + 24,
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title != "Vista Previa")
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: onBack,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 24);
}
