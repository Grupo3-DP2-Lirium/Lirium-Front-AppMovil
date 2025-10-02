import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/row_of_memories.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial_screen/relation_memorial_screen.dart';
import 'package:flutter_frontend/providers/memorial_provider.dart';
import 'package:provider/provider.dart';


class CreateMemoryToMemorial extends StatefulWidget {
  const CreateMemoryToMemorial({super.key});

  @override
  State<CreateMemoryToMemorial> createState() => _CreateMemoryToMemorialState();
}

class _CreateMemoryToMemorialState extends State<CreateMemoryToMemorial> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemorialProvider>(context, listen: false);
      print('DEBUG: Memoriales count - Mis: ${provider.misMemoriales.length}, Colab: ${provider.colaborativos.length}');
      provider.cargarMisMemoriales(force: true);  // Force reload
      provider.cargarColaborativos(force: true);  // Force reload
    });
  } 

  void _createMemorial(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewMemorialRelationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final memorialProvider = context.watch<MemorialProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Añade un recuerdo",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "¿A quién quieres recordar hoy?",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Text(
                "Mis memoriales",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 16),

            // Aquí podés pasar los datos a RowOfMemories o hacer que RowOfMemories también acceda al provider
            memorialProvider.cargandoMis
                ? Center(child: CircularProgressIndicator())
                : RowOfMemories(
              tipo: "memoriales",
              memoriales: memorialProvider.misMemoriales,
            ),

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Text(
                "Compartidos conmigo",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 16),

            Spacer(),

            PrimaryButton(
              text: 'Crear nuevo memorial',
              onPressed: () => _createMemorial(context),
            ),
          ],
        ),
      ),
    );
  }
}