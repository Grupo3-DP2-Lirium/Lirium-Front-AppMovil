import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/extra_storage_response.dart';
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
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:provider/provider.dart';
// VET/pO7}
class SubscriptionPlanDetailsScreen extends StatefulWidget {

  const SubscriptionPlanDetailsScreen({
    super.key,
  });

  @override
  State<SubscriptionPlanDetailsScreen> createState() =>
      _SubscriptionPlanDetailsScreenState();
}

class _SubscriptionPlanDetailsScreenState
    extends State<SubscriptionPlanDetailsScreen> {
  final SubscriptionService _service = SubscriptionService();
  bool _loadingPlan = true;

  @override
  void initState() {
    super.initState();
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
            //Navigator.pop(context);
            completer.complete(false);
          },
        ),
        AppPopupButton(
          text: "Sí",
          onPressed: () {
            //entNavigator.pop(context);
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
      // Solo refrescar si el widget sigue montado
      if (!mounted) return;
      final subProvider = context.read<SubscriptionProvider>();
      await subProvider.refreshPlan();

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

  Future<void> _cancelExtraStorage(ExtraStorageResponse extra) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Deseas cancelar este extra?"),
        content: Text(
            "Perderás ${extra.additionalStorageGb ?? 0} GB adicionales. Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sí")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      //await _service.cancelExtraStorage(extra.id);
      await context.read<SubscriptionProvider>().refreshPlan();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Extra storage cancelado correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cancelar extra storage")),
      );
    }
  }

  double bytesToGb(double bytes) => bytes / 1024 / 1024 / 1024;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09;
    final subProvider = context.watch<SubscriptionProvider>();

    if (!subProvider.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final subscription = subProvider.subscription;
    if (subscription == null) {
      return const Scaffold(
        body: Center(child: Text("No se encontró suscripción.")),
      );
    }

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
          child: Builder(
            builder: (context) {
              final subProvider = context.watch<SubscriptionProvider>();
              final subscription = subProvider.subscription;
              final permissions = subProvider.permissions;
              final loading = subProvider.isLoaded;

              if (!loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (subscription == null) {
                return const Center(child: Text("No se encontró suscripción."));
              }

              final planName = subscription.planName.toUpperCase();
              final bool hasEndDate = subscription.endDate != null;
              print("Plan recibido: '${subscription.planName}'");  // Esto muestra exactamente cómo viene el nombre
              print("Plan normalizado: '$planName'");             // Esto muestra cómo lo normalizamos a mayúsculas
              final bool planEnded = hasEndDate && subscription.endDate!.isBefore(DateTime.now());
              final bool planActive = !hasEndDate;
              final bool isFreeOrDescubre = planName == "Free" || planName == "DESCUBRE_LIRIUM";

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 185, // ajusta según tu card actual
                      child: PageView(
                        controller: PageController(viewportFraction: 0.9),
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Card del plan actual
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: currentPlanCard(
                              hasPlan: true,
                              planName: subscription.planName.isNotEmpty
                                  ? subscription.planName
                                  : "Sin nombre",
                              storage: "${(subscription.storageLimitGb ?? 0).toStringAsFixed(0)} GB",
                              startDate: subscription.startDate != null
                                  ? DateFormat('dd/MM/yyyy').format(subscription.startDate!)
                                  : "-",
                              renewalDate: (subscription.endDate == null && subscription.startDate != null)
                                  ? DateFormat('dd/MM/yyyy').format(
                                  subscription.frequency == 'YEARLY'
                                      ? subscription.startDate!.add(const Duration(days: 365))
                                      : subscription.startDate!.add(const Duration(days: 30)))
                                  : null,
                              endDate: subscription.endDate != null
                                  ? DateFormat('dd/MM/yyyy').format(subscription.endDate!)
                                  : null,
                            ),
                          ),

                          // Cards de extras
                          ...subProvider.extraStorage.map((extra) {
                            final start = extra.startDate;
                            final freq = "MONTHLY"; // default si no viene frequency

                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child:
                                currentPlanCard(
                                hasPlan: true,
                                planName: extra.planName,
                                storage: "${extra.additionalStorageGb ?? 0} GB extra",
                                startDate: extra.startDate != null ? DateFormat('dd/MM/yyyy').format(extra.startDate!) : null,
                                isExtra: true,
                                onCancelExtra: () async {
                                  await _cancelExtraStorage(extra); // aquí llamas a tu función
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PlanBenefitsList(
                        permissions: permissions,
                        maxCollaborations: subscription.maxCollaborations,
                        maxFilesPersonalSpace: subscription.maxFiles,
                        maxDocumentariesPerMonth: subscription.maxDocumentariesPerMonth,
                        supportLevel: subscription.supportLevel,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: () {
                        if (isFreeOrDescubre) {
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
                                    MaterialPageRoute(
                                      builder: (context) => const GetPremiumScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        if (hasEndDate && !planEnded) {
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
                                onPressed: () {},
                              ),
                            ],
                          );
                        }

                        if (hasEndDate && planEnded) {
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
                                    MaterialPageRoute(
                                      builder: (context) => const GetPremiumScreen(),
                                    ),
                                  );
                                  await subProvider.refreshPlan();
                                },
                              ),
                            ],
                          );
                        }

                        if (planActive) {
                          final String normalizedPlan = subscription.planName.toUpperCase();
                          return Column(
                            children: [
                              if (normalizedPlan == "CREA_REMORY" || normalizedPlan == "CREA_COMPARTE")
                                PrimaryButton(
                                  text: "Upgrade plan",
                                  color: AppColors.primary,
                                  onPressed: () async {
                                    await Navigator.push(
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
                                isOutlined: true,
                              ),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      }(),
                    ),
                    const SizedBox(height: 24),
                    FutureBuilder<List<double>>(
                      future: Future.wait([
                        StorageService.getUsedSpace(),
                        StorageService.getTotalCapacity(),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final usedGb = bytesToGb(snapshot.data![0]);
                        final maxGb = bytesToGb(snapshot.data![1]);

                        return storageUsageCard(
                          usedBytes: usedGb,
                          maxBytes: maxGb,
                        );
                      },
                    ),
                    if (subscription.planName.toUpperCase() == "LEGADO_ETERNO" &&
                        subscription.endDate == null &&
                        subProvider.extraStorage.length < 3) // <-- solo mostrar si tiene menos de 3 extras
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: PrimaryButton(
                          text: "Agregar espacio extra",
                          color: AppColors.primary2,
                          isEnabled: true,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ExtraStorageScreen()),
                            );
                            setState(() {});
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        )
    );
  }
}