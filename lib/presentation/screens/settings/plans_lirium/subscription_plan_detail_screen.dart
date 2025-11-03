import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/subscription_response.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:intl/intl.dart';
// VET/pO7}
class SubscriptionPlanDetailsScreen extends StatefulWidget {
  final int usedStorageGB;
  final int totalStorageGB;

  const SubscriptionPlanDetailsScreen({
    super.key,
    required this.usedStorageGB,
    required this.totalStorageGB,
  });

  @override
  State<SubscriptionPlanDetailsScreen> createState() =>
      _SubscriptionPlanDetailsScreenState();
}

class _SubscriptionPlanDetailsScreenState
    extends State<SubscriptionPlanDetailsScreen> {
  late Future<SubscriptionResponse> _subscriptionFuture;
  final SubscriptionService _subscriptionService = SubscriptionService(); // instancia del servicio
  final SubscriptionService _service = SubscriptionService();

  @override
  void initState() {
    super.initState();
    _subscriptionFuture = _subscriptionService.getCurrentSubscription();
  }

  @override
  Widget build(BuildContext context) {
    double usedPercent = widget.usedStorageGB / widget.totalStorageGB;

    return Scaffold(
      appBar: AppBar(title: const Text("Detalles de la Suscripción")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<SubscriptionResponse>(
          future: _subscriptionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      "Error cargando la suscripción: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No se encontró suscripción."));
            }

            final subscription = snapshot.data!;
            final planName = subscription.planName;
            final planPrice =
            subscription.planPrice == 0 ? 'Gratis' : '\$${subscription.planPrice.toStringAsFixed(2)}';
            final frequency = subscription.frequency.isNotEmpty
                ? subscription.frequency
                : 'Mensual';
            final startDate = subscription.startDate != null
                ? DateFormat('dd/MM/yyyy').format(subscription.startDate!)
                : '-';
            final endDate = subscription.endDate != null
                ? DateFormat('dd/MM/yyyy').format(subscription.endDate!)
                : '-';
            final paymentMethod = subscription.paymentMethod ?? 'N/A';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de almacenamiento
                  /*Text(
                    "Almacenamiento",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      "Has usado ${widget.usedStorageGB} GB de ${widget.totalStorageGB} GB"),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: usedPercent,
                      minHeight: 12,
                      color: Colors.redAccent,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),*/
                  const SizedBox(height: 24),

                  // Sección del plan
                  Text(
                    "Plan Actual",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(planName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(subscription.planDescription),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Precio: $planPrice"),
                              Text("Frecuencia: $frequency"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Inicio: $startDate"),
                              Text("Vence: $endDate"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Método de pago: $paymentMethod"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón cambiar plan
                  Center(
                    child: PrimaryButton(
                      text: "Cambiar de plan",
                      color: AppColors.primary2,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GetPremiumScreen(),
                          ),
                        );
                      },
                      icon: Icons.swap_horiz, // si tu PrimaryButton lo acepta
                    )
                  ),

                  const SizedBox(height: 16),

                  // Botón cancelar suscripción
                  Center(
                    child: PrimaryButton(
                      text: "Cancelar plan",
                      onPressed: () async {
                        try {
                          await _service.cancelPaypalSubscription();
                          // Mostrar mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Suscripción cancelada exitosamente"))
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error al cancelar la suscripción"))
                          );
                        }
                      },
                      icon: Icons.cancel,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
