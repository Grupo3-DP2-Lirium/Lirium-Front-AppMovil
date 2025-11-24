import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/paypal_web_view.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/receipt_paypal.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
// lucia512@personal.example.com
// VET/pO7}
class ExtraDocumentalesScreen extends StatefulWidget {
  const ExtraDocumentalesScreen({super.key});

  @override
  State<ExtraDocumentalesScreen> createState() => _ExtraDocumentalesScreenState();
}

class _ExtraDocumentalesScreenState extends State<ExtraDocumentalesScreen> {
  int selectedCombo = 0; // índice del combo seleccionado
  final List<Map<String, dynamic>> combos = [
    {"name": "¡Aventura! Combo 1", "documentales": 1, "price": 2.99},
    {"name": "¡Explora! Combo 2", "documentales": 3, "price": 5.99},
    {"name": "¡Descubre! Combo 3", "documentales": 5, "price": 9.99},
    {"name": "¡Épico! Combo 4", "documentales": 10, "price": 17.99},
  ];

  void _selectCombo(int index) {
    setState(() {
      selectedCombo = index;
    });
  }

  void _applyCombo() async {
    final provider = context.read<SubscriptionProvider>();
    final sub = provider.subscription;
    if (sub != null) {
      final added = combos[selectedCombo]["documentales"] as int;

      // Actualizar UI
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Se agregaron $added documentales extra")),
      );
    }
  }

  Future<void> _subscribe() async {
    final provider = context.read<SubscriptionProvider>();
    final sub = provider.subscription;
    if (sub == null) return;

    final selected = combos[selectedCombo];
    final int documentariesToBuy = selected['documentales'] as int;
    final double amount = selected['price'] as double;

    try {
      // Llamada al service que ya hace el POST
      final orderData = await SubscriptionService().createExtraDocumentaryOrder(
        amount: amount,
        quantity: documentariesToBuy,
      );

      final approvalLink = orderData['approvalLink'];

      if (approvalLink == null || approvalLink.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar el pago.')),
        );
        return;
      }

      // Abrir WebView para aprobar pago
      final paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayPalWebViewScreen(
            url: approvalLink,
            quantity: documentariesToBuy,
          ),
        ),
      );

      if (paymentResult != null &&
          paymentResult is Map<String, dynamic> &&
          paymentResult['status'] == 'success') {

        // Leer valores actuales del storage
        int purchased = await StorageService.getDocumentariesPurchased() ?? 0;
        int available = await StorageService.getDocumentariesAvailable() ?? 0;

        // Sumar los documentales comprados
        purchased += documentariesToBuy;
        available += documentariesToBuy;

        // Guardar de nuevo
        await StorageService.saveDocumentariesPurchased(purchased);
        await StorageService.saveDocumentariesAvailable(available);

        // Actualizar UI
        setState(() {});
        PaypalReceiptPopup.show(context, paymentResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago cancelado o fallido')),
        );
      }
    } catch (e) {
      print('Error en suscripción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Documentales Extra",
        onBack: () => Navigator.pop(context),
        appBarHeight: appBarHeight,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
                "Elige un combo de documentales extra",
                style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // BOX DE DOCUMENTALES
            // Reemplaza este Consumer<SubscriptionProvider> {...}
            FutureBuilder(
              future: Future.wait([
                StorageService.getDocumentariesPurchased(),
                StorageService.getDocumentariesAvailable(),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink(); // o un CircularProgressIndicator si quieres
                }

                final purchased = snapshot.data![0] as int;
                final available = snapshot.data![1] as int;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Adquiridos",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$purchased",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Disponibles",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$available",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: combos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final combo = combos[index];
                  final isSelected = selectedCombo == index;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectCombo(index),
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [AppColors.primary.withOpacity(0.3), AppColors.primary]
                              : [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 28,
                            color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.5),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // NOMBRE + PRECIO EN LA MISMA FILA
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        combo['name'] ?? "Combo",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "\$${combo['price'].toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${combo['documentales']} documentales",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: "Comprar Documentales",
              color: AppColors.primary2,
              onPressed: () async {
                await _subscribe();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
