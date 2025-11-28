import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_title.dart';
import 'package:flutter_frontend/presentation/components/forms/search_field.dart';
import 'package:flutter_frontend/presentation/screens/main/widgets/memorial_card.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentary_details_screen.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';

class SelectMemorialDocumentaryScreen extends StatefulWidget {
  const SelectMemorialDocumentaryScreen({super.key});

  @override
  State<SelectMemorialDocumentaryScreen> createState() =>
      _SelectMemorialDocumentaryScreenState();
}

class _SelectMemorialDocumentaryScreenState
    extends State<SelectMemorialDocumentaryScreen> {
  String searchQuery = "";
  bool _validating = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      if (provider.misMemoriales.isEmpty) {
        provider.cargarMisMemoriales(force: true);
      }
    });
  }

  Future<void> _onMemorialSelected(String memorialId, String memorialName) async {
    setState(() {
      _validating = true;
      _validationError = null;
    });

    final documentaryProvider = context.read<DocumentaryProvider>();
    final validation = await documentaryProvider.validateMemorial(memorialId);

    if (!mounted) return;

    if (validation == null) {
      setState(() {
        _validating = false;
        _validationError = 'Error al validar el memorial';
      });
      return;
    }

    final bool isValid = validation['isValid'] ?? false;
    final int currentMemories = validation['currentMemories'] ?? 0;
    final int minimumRequired = validation['minimumRequired'] ?? 50;

    setState(() {
      _validating = false;
    });

    if (!isValid) {
      _showInsufficientMemoriesDialog(
        memorialName,
        currentMemories,
        minimumRequired,
        validation['message'] ?? 'No hay suficientes recuerdos',
      );
      return;
    }

    // Si tiene suficientes recuerdos, continuar
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentaryDetailsScreen(
          memorialId: memorialId,
          memorialName: memorialName,
        ),
      ),
    );
  }

  void _showInsufficientMemoriesDialog(
      String memorialName,
      int current,
      int required,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Expanded(child: Text('Recuerdos insuficientes')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '$current',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const Text(
                        'Actuales',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text(
                        '$required',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Requeridos',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
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
      body: _validating
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Validando memorial...'),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTitle(
              title: "Crear Documental",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "¿Sobre quién será este documental?",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppSearchBar(
              hintText: "Busca un memorial...",
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 24),

            if (_validationError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Mis memoriales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mis memoriales", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),

                  // SizedBox con altura fija
                  SizedBox(
                    height: 180, // 160–200 queda bien
                    child: misFiltrados.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
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
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: misFiltrados.length,
                      itemBuilder: (_, index) {
                        final m = misFiltrados[index];
                        // Ancho fijo o proporcional al ancho de pantalla
                        final cardWidth = MediaQuery.of(context).size.width * 0.35; // o 140–160 px

                        return SizedBox(
                          width: cardWidth,
                          child: AspectRatio(
                            aspectRatio: 3 / 4, // mantiene proporción agradable
                            child: MemorialCard(
                              memorial: m,
                              onTap: () => _onMemorialSelected(m.idMemorial, m.name),
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