import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/extra_storage_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/paypal_web_view_extra_storage.dart';
// VET/pO7}

class ExtraStorageScreen extends StatefulWidget {
  const ExtraStorageScreen({super.key});

  @override
  State<ExtraStorageScreen> createState() => _ExtraStorageScreenState();
}

class _ExtraStorageScreenState extends State<ExtraStorageScreen> {
  int selectedPlanIndex = 0; // Plan seleccionado por defecto
  bool _isLoadingPlans = false;
  bool _isLoadingPaypal = false;
  List<Map<String, dynamic>> plans = [];
  final extraService = ExtraStorageService();
  String? currentPlan;

  @override
  void initState() {
    super.initState();
    _loadExtraPlans();
  }

  Future<void> _loadExtraPlans() async {
    setState(() => _isLoadingPlans = true);

    try {
      final loadedPlans = await extraService.listExtraStoragePlans();

      // Filtrar solo los planes válidos
      final filteredPlans = loadedPlans.where((plan) => (plan['idExtraPlan'] ?? "").isNotEmpty).toList();

      setState(() {
        plans = filteredPlans;
      });

      print("Planes recibidos: $filteredPlans");
    } catch (e) {
      print("Error cargando planes de almacenamiento extra: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando planes de almacenamiento extra: $e")),
      );
    } finally {
      setState(() => _isLoadingPlans = false);
    }
  }

  Future<void> _subscribeExtraStorage() async {
    if (plans.isEmpty) return;

    final plan = plans[selectedPlanIndex];
    final String paypalPlanId = plan['paypalPlanId'];
    final String internalPlanId = plan['idExtraPlan'];

    try {
      setState(() => _isLoadingPaypal = true);

      // Pop-up de carga mientras se crea la suscripción
      appPopupButtonDefault(
        context: context,
        title: "Procesando...",
        message: "Estamos creando tu suscripción. Por favor espera.",
        buttons: [AppPopupButton(text: "", onPressed: () {})],
        isLoading: true,
      );

      final response = await extraService.createExtraStorageSubscription(
        paypalPlanId: paypalPlanId,
        extraPlanId: internalPlanId,
      );

      Navigator.pop(context); // cerrar popup de carga

      final approvalLink = response['approvalLink'];
      final subscriptionId = response['subscriptionID'];

      if (approvalLink == null || approvalLink.isEmpty) {
        throw Exception("No se recibió approvalLink de PayPal");
      }

      // Abrimos PayPal WebView para el pago
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayPalWebViewExtraStorage(
            url: approvalLink,
            extraPlanId: internalPlanId,
            subscriptionId: subscriptionId,
            frequency: "MONTHLY",
          ),
        ),
      );

      if (result != null && result is Map && result['status'] == "success") {
        // Guardar el plan en StorageService
        /*await StorageService.savePlan(plan['name']);

        // Obtener y guardar los permisos actualizados
        final updatedPermissions =
        await subscriptionService.getPlanPermissions(plan['idPlan']);
        await StorageService.savePermissions(updatedPermissions);

        // Actualizar estado local del widget
        setState(() {
          currentPlan = plan['name'];
        });

        final userPermissions = await StorageService.getPermissions();

        print("Plan actualizado: $currentPlan");
        print("Permisos actualizados: $userPermissions");
        */
        // Mostrar popup de éxito
        await appPopupButtonDefault(
          context: context,
          title: "¡Suscripción exitosa!",
          message:
          "Tu suscripción ha sido activada correctamente. Ahora tienes acceso a todos los beneficios del plan ${plan['name']}.",
          buttons: [
            AppPopupButton(
              text: "Aceptar",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      } else {
        // Mostrar popup si el usuario no completó el pago
        await appPopupButtonDefault(
          context: context,
          title: "Suscripción incompleta",
          message:
          "La suscripción no fue completada. Puedes intentarlo nuevamente.",
          buttons: [
            AppPopupButton(
              text: "Cerrar",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    } catch (e) {
      Navigator.pop(context, null); // cerrar pop-up de carga si quedó abierto

      // Mostrar popup de error
      await appPopupButtonDefault(
        context: context,
        title: "Error",
        message: "Ocurrió un problema al crear la suscripción.\nDetalles: $e",
        buttons: [
          AppPopupButton(
            text: "Cerrar",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    } finally {
      setState(() => _isLoadingPaypal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Agregar espacio extra",
        onBack: () => Navigator.pop(context),
        appBarHeight: appBarHeight,
        showBackButton: true,
      ),
      body: _isLoadingPlans
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Selecciona un plan de espacio extra a la vez:",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = selectedPlanIndex == index; // <-- usar el index directamente

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => selectedPlanIndex = index), // <-- actualizar el índice
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [AppColors.primary.withOpacity(0.3), plan['color'] ?? AppColors.primary]
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
                      child: Stack(
                        children: [
                          Row(
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
                                    Text(
                                      plan['name'] ?? "Plan Extra",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      plan['description'] ?? "",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: isSelected ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "\$${plan['price'] ?? 0}",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                plan['frequency'] ?? "Mensual",
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
              text: _isLoadingPaypal ? "Procesando..." : "Suscribirse",
              color: AppColors.primary2,
              onPressed: _isLoadingPaypal ? null : _subscribeExtraStorage,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
