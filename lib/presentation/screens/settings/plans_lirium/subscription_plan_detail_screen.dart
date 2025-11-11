import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/subscription_response.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/buttons/secondary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/get_premium_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/current_plan_card.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/extra_storage_screen.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/plan_benefits_list.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/storage_use_card.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SubscriptionPlanDetailsScreen extends StatefulWidget {
  final double usedStorageGB;
  final double totalStorageGB;

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
  final SubscriptionService _service = SubscriptionService();
  Future<SubscriptionResponse>? _currentSubscription;
  bool _loadingPlan = true;
  List<String> _permissions = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final plan = await StorageService.getPlan();
      final permissions = await StorageService.getPermissions();

      print("Plan guardado del usuario: $plan");
      print("Permisos guardados del usuario: $permissions");

      setState(() {
        _permissions = permissions;
        _currentSubscription = SubscriptionService().getCurrentSubscription();
      });
    } catch (e, stack) {
      print("Error cargando plan actual: $e");
      print(stack);
      _currentSubscription = Future.value(
        SubscriptionResponse(
          subscriptionId: null,
          status: "ERROR",
          frequency: "",
          startDate: null,
          endDate: null,
          paymentMethod: null,
          planId: null,
          planName: "Error al cargar",
          planDescription: "No se pudo obtener el plan actual",
          planPrice: 0,
          planCurrency: "USD",
          storageLimitGb: 0,
        ),
      );
    } finally {
      setState(() => _loadingPlan = false);
    }
  }

  Future<void> _cancelSubscription(BuildContext context) async {
    // Mostrar popup de confirmación y esperar respuesta
    final completer = Completer<bool>();

    await appPopupButtonDefault(
      context: context,
      title: "¿Estás seguro de que quieres cancelar tu plan?",
      message:
      "Perderás acceso a los beneficios de tu suscripción actual.",
      buttons: [
        AppPopupButton(
          text: "No",
          onPressed: () {
            Navigator.pop(context);
            completer.complete(false);
          },
        ),
        AppPopupButton(
          text: "Sí",
          onPressed: () {
            Navigator.pop(context);
            completer.complete(true);
          },
        ),
      ],
    );

    final confirm = await completer.future;
    if (!confirm) return; // si el usuario cancela, salir

    // Mostrar popup de carga
    appPopupButtonDefault(
      context: context,
      title: "",
      message: "",
      buttons: [AppPopupButton(text: "", onPressed: () {})],
      isLoading: true,
    );

    try {
      // Llamar servicio de cancelación
      await _service.cancelPaypalSubscription();

      Navigator.pop(context); // cerrar popup de carga

      // Mostrar popup de éxito
      await appPopupButtonDefault(
        context: context,
        title: "Suscripción cancelada 💔",
        message: "Tu plan ha sido cancelado exitosamente.",
        buttons: [
          AppPopupButton(
            text: "Aceptar",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    } catch (e) {
      Navigator.pop(context); // cerrar popup de carga en caso de error

      // Mostrar popup de error
      await appPopupButtonDefault(
        context: context,
        title: "Error",
        message: "No se pudo cancelar la suscripción. Inténtalo nuevamente.",
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
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: "Mi Plan",
        onBack: () => Navigator.pop(context),
        appBarHeight: appBarHeight,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<SubscriptionResponse>(
          future: _currentSubscription,
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
            final planName = subscription.planName.toUpperCase();

            // Detectar si es FREE o DESCUBRE_REMORY
            final isFreeOrDescubre = planName == "FREE" || planName == "DESCUBRE_REMORY";

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                currentPlanCard(
                  hasPlan: true,
                  planName: subscription.planName.isNotEmpty
                      ? subscription.planName
                      : "Sin nombre",
                  storage: "${(subscription.storageLimitGb ?? 0).toStringAsFixed(0)} GB",
                  startDate: subscription.startDate != null
                      ? DateFormat('dd/MM/yyyy').format(subscription.startDate!)
                      : "-",
                  // Si tiene endDate, no calculamos renovación
                  renewalDate: (subscription.endDate == null)
                      ? (subscription.startDate != null
                      ? (() {
                    final nextRenewal = subscription.frequency == 'YEARLY'
                        ? subscription.startDate!.add(const Duration(days: 365))
                        : subscription.startDate!.add(const Duration(days: 30));
                    return DateFormat('dd/MM/yyyy').format(nextRenewal);
                  })()
                      : "-")
                      : null,

                  endDate: (subscription.endDate != null)
                      ? DateFormat('dd/MM/yyyy').format(subscription.endDate!)
                      : null,
                ),
                const SizedBox(height: 24),
                  PlanBenefitsList(permissions: _permissions),
                  const SizedBox(height: 16),
                  Center(
                    child: (subscription.endDate != null || isFreeOrDescubre)
                        ? Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          subscription.endDate != null
                              ? "Suscribete para seguir disfrutando de todos los beneficios de Lirium"
                              : "Desbloquea todos los beneficios de Lirium",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: "Suscribirme",
                          color: AppColors.primary2,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GetPremiumScreen(),
                              ),
                            );
                            if (mounted) {
                              setState(() => _loadingPlan = true);
                              await _loadCurrentPlan();
                            }
                          },
                        ),
                        // === NUEVO BOTÓN SOLO PARA LEGADO_ETERNO ACTIVO ===
                        if (subscription.planName.toUpperCase() == "LEGADO_ETERNO" && subscription.endDate == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: PrimaryButton(
                              text: "Agregar espacio extra",
                              color: AppColors.primary,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ExtraStorageScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    )
                        : Column(
                      children: [
                        PrimaryButton(
                          text: "Cambiar de plan",
                          color: AppColors.primary,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GetPremiumScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          text: "Cancelar plan",
                          onPressed: () async {
                            await _cancelSubscription(context);
                          },
                          isOutlined: true
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  storageUsageCard(
                    usedGb: widget.usedStorageGB,
                    maxGb: subscription.storageLimitGb ?? 0,
                  ),
                  // === BOTÓN AGREGAR ESPACIO EXTRA SOLO PARA LEGADO_ETERNO ACTIVO ===
                  if (subscription.planName.toUpperCase() == "LEGADO_ETERNO" && subscription.endDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0), // un poco de espacio arriba
                      child: PrimaryButton(
                        text: "Agregar espacio extra",
                        color: AppColors.primary2,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExtraStorageScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
