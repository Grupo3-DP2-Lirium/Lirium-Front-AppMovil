import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/screens/create_memory_for_a_memorial/row_of_memories.dart';
import 'package:flutter_frontend/presentation/screens/memorial/new_memorial/relation_memorial_screen.dart';


class CreateMemoryToMemorial extends StatelessWidget {
  const CreateMemoryToMemorial({super.key});

  void _createMemorial(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewMemorialRelationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
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
            RowOfMemories(tipo: "memoriales"),
            SizedBox(
              width: double.infinity,
              child: Text(
                "Compartidos conmigo",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 16),
            RowOfMemories(tipo: "compartido"),
            Spacer(),
            PrimaryButton(text: 'Crear nuevo memorial', onPressed: () => _createMemorial(context)),
          ],
        ),
      ),
    );
  }
}
