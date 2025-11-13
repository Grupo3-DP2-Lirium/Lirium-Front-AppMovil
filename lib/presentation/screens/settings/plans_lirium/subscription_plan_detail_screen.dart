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
// VET/pO7}
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
      "Perderás acceso a los beneficios de tu suscripción actual."
      "Tendrás 6 meses para renovarla; pasado ese tiempo, todo lo creado será eliminado permanentemente.",
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
        title: "Suscripción cancelada",
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

            // Estados principales
            final bool hasEndDate = subscription.endDate != null;
            final bool planEnded = hasEndDate && subscription.endDate!.isBefore(DateTime.now());
            final bool planActive = !hasEndDate; // Si no tiene endDate, está activo
            final bool isFreeOrDescubre = planName == "FREE" || planName == "DESCUBRE_REMORY";

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
                    child: () {
                      if (isFreeOrDescubre) {
                        // === Plan gratuito o sin plan ===
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              "Desbloquea todos los beneficios de Lirium",
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
                                  MaterialPageRoute(builder: (context) => const GetPremiumScreen()),
                                );
                                if (mounted) {
                                  setState(() => _loadingPlan = true);
                                  await _loadCurrentPlan();
                                }
                              },
                            ),
                          ],
                        );
                      }

                      if (hasEndDate && !planEnded) {
                        // === Cancelado pero todavía vigente ===
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              "Tu plan finalizará el ${DateFormat('dd/MM/yyyy').format(subscription.endDate!)}.\nPodrás volver a suscribirte una vez finalice.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              text: "Suscribirme",
                              color: AppColors.primary2,
                              isEnabled: false,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const GetPremiumScreen()),
                                );
                                if (mounted) {
                                  setState(() => _loadingPlan = true);
                                  await _loadCurrentPlan();
                                }
                              },
                            ),
                          ],
                        );
                      }

                      if (hasEndDate && planEnded) {
                        // === Cancelado y ya terminó ===
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              "Tu plan finalizó. Vuelve a suscribirte para seguir disfrutando de los beneficios.",
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
                                  MaterialPageRoute(builder: (context) => const GetPremiumScreen()),
                                );
                                if (mounted) {
                                  setState(() => _loadingPlan = true);
                                  await _loadCurrentPlan();
                                }
                              },
                            ),
                          ],
                        );
                      }

                      if (planActive) {
                        // === Plan activo ===

                        // Determinar si el botón debe decir Upgrade o Downgrade
                        final String normalizedPlan = subscription.planName.toUpperCase();
                        String actionText;

                        if (normalizedPlan == "CREA_REMORY" || normalizedPlan == "CREA_COMPARTE") {
                          actionText = "Upgrade plan";
                        }

                        return Column(
                          children: [
                            if (normalizedPlan == "CREA_REMORY" || normalizedPlan == "CREA_COMPARTE")
                              PrimaryButton(
                                text: "Upgrade plan",
                                color: AppColors.primary,
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const GetPremiumScreen()),
                                  );
                                  if (mounted) {
                                    setState(() => _loadingPlan = true);
                                    await _loadCurrentPlan();
                                  }
                                },
                              ),
                            const SizedBox(height: 16),
                            SecondaryButton(
                              text: "Cancelar plan",
                              onPressed: () async {
                                await _cancelSubscription(context);
                                await _loadCurrentPlan();
                              },
                              isOutlined: true,
                            ),
                          ],
                        );
                      }
                    }(),
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
