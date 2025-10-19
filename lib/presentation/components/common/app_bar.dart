import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/navigation/tab_bar.dart';

class CustomMemoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final TabController? tabController;
  final List<Tab>? tabs;
  final bool showBackButton;
  final double appBarHeight;

  const CustomMemoryAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.tabController,
    this.tabs,
    this.showBackButton = false,
    required this.appBarHeight,  // Pasamos la altura calculada
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.5),
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // Fila con el Icono de retroceso y el título
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showBackButton && title != "Vista Previa")
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
                  const SizedBox(width: 48),  // Espacio vacío a la derecha
                ],
              ),

              // Si hay TabBar, lo mostramos
              if (tabs != null && tabController != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Tab_Bar(
                      controller: tabController!,
                      tabs: tabs!
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(appBarHeight);  // Usamos la altura calculada
  }
}
