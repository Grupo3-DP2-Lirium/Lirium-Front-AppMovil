import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'package:flutter_frontend/presentation/components/forms/search_field.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/memorial_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsule_prompt_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';

class SelectMemorialCapsuleScreen extends StatefulWidget {
  const SelectMemorialCapsuleScreen({super.key});

  @override
  State<SelectMemorialCapsuleScreen> createState() =>
      _SelectMemorialCapsuleScreenState();
}

class _SelectMemorialCapsuleScreenState
    extends State<SelectMemorialCapsuleScreen> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      provider.cargarMisMemoriales(force: true);
    });
  }

  void _onMemorialSelected(String memorialId, String memorialName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CapsulePromptScreen(
          memorialId: memorialId,
          memorialName: memorialName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memorialProvider = context.watch<MemorialProvider>();

    final misFiltrados = memorialProvider.misMemoriales
        .where((m) =>
        m.nickname.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const SizedBox.shrink(),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTitle(
              title: "Crear Cápsula",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "¿Sobre quién será esta cápsula?",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppSearchBar(
              hintText: "Busca un memorial...",
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 24),

            // Mis memoriales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mis memoriales",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 180,
                    child: misFiltrados.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.isEmpty
                                ? 'No tienes memoriales aún'
                                : 'No se encontraron resultados',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 4),
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemCount: misFiltrados.length,
                      itemBuilder: (_, index) {
                        final m = misFiltrados[index];
                        final cardWidth =
                            MediaQuery.of(context).size.width * 0.35;

                        return SizedBox(
                          width: cardWidth,
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: MemorialCard(
                              memorial: m,
                              onTap: () => _onMemorialSelected(
                                  m.idMemorial, m.name),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}