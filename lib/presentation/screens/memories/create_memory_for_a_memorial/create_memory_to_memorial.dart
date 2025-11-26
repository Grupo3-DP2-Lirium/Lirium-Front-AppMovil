import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'package:flutter_frontend/presentation/components/forms/search_field.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/memorial_card.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
import 'package:flutter_frontend/presentation/screens/memories/create_memory_for_a_memorial/create_memory_select_type.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';

class CreateMemoryToMemorial extends StatefulWidget {
  const CreateMemoryToMemorial({super.key});

  @override
  State<CreateMemoryToMemorial> createState() =>
      _CreateMemoryToMemorialState();
}

class _CreateMemoryToMemorialState extends State<CreateMemoryToMemorial> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      if (provider.misMemoriales.isEmpty) {
        provider.cargarMisMemoriales(force: true);
      }
      if (provider.colaborativos.isEmpty) {
        provider.cargarColaborativos(force: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final memorialProvider = context.watch<MemorialProvider>();

    // Filtrado por search
    final misFiltrados = memorialProvider.misMemoriales
        .where(
            (m) => m.nickname.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    final colabFiltrados = searchQuery.isEmpty
        ? memorialProvider.colaborativos
        : memorialProvider.colaborativos
        .where(
            (m) => m.nickname.toLowerCase().contains(searchQuery.toLowerCase()))
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
          crossAxisAlignment: CrossAxisAlignment.stretch, // ocupa todo el ancho disponible
          children: [
            const AppTitle(
              title: "Crea un Recuerdo",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "¿A quién quieres recordar hoy?",
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
                  Text("Mis memoriales", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: misFiltrados.length,
                      padding: const EdgeInsets.only(right: 0),
                      itemBuilder: (_, index) => Padding(
                        padding: EdgeInsets.only(
                          right: index == misFiltrados.length - 1 ? 0 : 12,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: MemorialCard(
                            memorial: misFiltrados[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateMemorySelectType(
                                    memorialId: misFiltrados[index].idMemorial,
                                    memorialName: misFiltrados[index].nickname,
                                  ),
                                ),
                              );
                            },
                          ),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Colaboraciones", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: colabFiltrados.length,
                      padding: const EdgeInsets.only(right: 0),
                      itemBuilder: (_, index) => Padding(
                        padding: EdgeInsets.only(
                          right: index == colabFiltrados.length - 1 ? 0 : 12,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: MemorialCard(
                            memorial: colabFiltrados[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateMemorySelectType(
                                    memorialId: colabFiltrados[index].idMemorial,
                                    memorialName: colabFiltrados[index].nickname,
                                  ),
                                ),
                              );
                            },
                          ),
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
    );
  }
}
