import 'package:flutter/material.dart';

class SubscriptionPlanDetailsScreen extends StatelessWidget {
  final int usedStorageGB;
  final int totalStorageGB;
  final String currentPlan;

  const SubscriptionPlanDetailsScreen({
    super.key,
    required this.usedStorageGB,
    required this.totalStorageGB,
    this.currentPlan = "Plan Gratuito",
  });

  @override
  Widget build(BuildContext context) {
    double usedPercent = usedStorageGB / totalStorageGB;

    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Almacenamiento",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Has usado $usedStorageGB GB de tus $totalStorageGB GB disponibles"),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width * usedPercent,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Plan actual",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(currentPlan, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí mostrarías los otros planes para cambiar
              },
              child: const Text("Cambiar de plan"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Cancelar suscripción",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
              ),
              onPressed: () {
                // Aquí devolverías al plan gratuito
              },
              child: const Text("Volver al Plan Gratuito"),
            ),
          ],
        ),
      ),
    );
  }
}