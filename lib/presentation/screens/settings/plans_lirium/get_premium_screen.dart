import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/components/common/app_pop_up.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/paypal_web_view.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/paypal_web_view2.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/plan_card.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/premium_tab_selector.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/receipt_paypal.dart';
import 'package:flutter_frontend/providers/plan_provider.dart';
import 'package:provider/provider.dart';
// VET/pO7}

class GetPremiumScreen extends StatefulWidget {
  const GetPremiumScreen({super.key});

  @override
  State<GetPremiumScreen> createState() => _GetPremiumScreenState();
}

class _GetPremiumScreenState extends State<GetPremiumScreen> {
  bool isMonthly = true;
  int selectedPlanIndex = 0; // Plan seleccionado por defecto
  bool _isLoadingPlans = false;
  bool _isLoadingPaypal = false;
  List<Map<String, dynamic>> plans = [];
  final subscriptionService = SubscriptionService();
  String? currentPlan;
  late final subProvider = context.watch<SubscriptionProvider>();

  Future<void> _subscribeRecurring() async {
    if (plans.isEmpty) return;

    final plan = plans[selectedPlanIndex];
    final String paypalPlanId = plan['paypalPlanId'];
    final String internalPlanId = plan['idPlan'];

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

      final response = await subscriptionService.createPaypalSubscription(
        paypalPlanId: paypalPlanId,
        planId: internalPlanId,
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
          builder: (_) => PayPalWebViewScreen2(
            url: approvalLink,
            planId: internalPlanId,
            isSubscription: true,
            subscriptionId: subscriptionId,
            frequency: isMonthly ? "MONTHLY" : "YEARLY",
          ),
        ),
      );

      if (result != null && result is Map && result['status'] == "success") {
        // Guardar el plan en StorageService
        //await StorageService.savePlan(plan['name']);

        // Obtener y guardar los permisos actualizados
        final updatedPermissions =
        await subscriptionService.getPlanPermissions(plan['idPlan']);
        //await StorageService.savePermissions(updatedPermissions);

        // Actualizar estado local del widget
        setState(() {
          currentPlan = plan['name'];
        });

        //final userPermissions = await StorageService.getPermissions();

        print("Plan actualizado: $currentPlan");
        //print("Permisos actualizados: $userPermissions");

        if (mounted) {
          final subscriptionProvider = context.read<SubscriptionProvider>();
          await subscriptionProvider.refreshPlan();

          // New Capacity
          const gbInBytes = 1024 * 1024 * 1024;
          final newTotalBytes = plan['storageLimitGb'] * gbInBytes;
          await StorageService.saveTotalCapacity(newTotalBytes);

        }
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
                if (mounted) Navigator.pop(context);
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
                if (mounted) Navigator.pop(context);
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
      if (mounted) {
        setState(() => _isLoadingPaypal = false);
      }
    }
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoadingPlans = true;
    });

    try {
      final loadedPlans = await SubscriptionService.loadPlans();

      // Filtrar para excluir el plan "FREE"
      final filteredPlans = loadedPlans.where((plan) {
        final name = (plan['name'] ?? '').toString().toLowerCase();
        final price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;
        return name != 'free' && price > 0;
      }).toList();

      setState(() {
        plans = filteredPlans;
      });
    } catch (e) {
      print('Error al cargar planes en pantalla: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los planes: $e')),
      );
    } finally {
      setState(() {
        _isLoadingPlans = false;
      });
    }
  }

  List<Map<String, dynamic>> getFilteredPlans() {
    if (plans.isEmpty) return [];

    // Excluir los planes con price 0
    final nonFreePlans = plans.where((plan) {
      final price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;
      return price > 0;
    }).toList();

    if (isMonthly) {
      // Solo CREA_COMPARTE
      return nonFreePlans.where((plan) {
        final name = (plan['name'] ?? '').toString().toUpperCase();
        return name == 'CREA_COMPARTE';
      }).toList();
    } else {
      // Solo LEGADO ETERNO
      return nonFreePlans.where((plan) {
        final name = (plan['name'] ?? '').toString().toUpperCase();
        return name == 'LEGADO_ETERNO';
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlans();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF303742)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // --- Imagen y texto principal ---
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/images/lirium_icon.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sé Premium",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFC7171),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 290,
                      child: Text(
                        "Desbloquea todo el poder de Lyrium y preserva tu historia",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(217, 146, 147, 0.93),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // --- Tabs Mensual / Anual ---
                PremiumTabSelector(
                  isMonthly: isMonthly,
                  onTabChanged: (value) {
                    setState(() {
                      isMonthly = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // --- Cards de planes ---
                Column(
                  children: [
                    if (_isLoadingPlans)
                      const Center(child: CircularProgressIndicator())
                    else
                      for (var plan in getFilteredPlans())
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PlanCard(
                            title: plan['name'] ?? '',
                            description: plan['description'] ?? '',
                            price: () {
                              final double basePrice = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;
                              final String currency = plan['currency'] ?? 'USD';
                              return '$currency ${basePrice.toStringAsFixed(2)}';
                            }(),
                            recommended: false,
                            isSelected: selectedPlanIndex == plans.indexOf(plan),
                            onTap: () {
                              setState(() {
                                selectedPlanIndex = plans.indexOf(plan);
                              });
                            },
                            permissions: plan['permissions'] != null
                                ? (plan['permissions'] as List).map((p) => p['name'].toString()).toList()
                                : [],
                            // Atributos extra - Convertir double a int si es necesario
                            storageLimitGb: plan['storageLimitGb'] != null 
                                ? (plan['storageLimitGb'] is int 
                                    ? plan['storageLimitGb'] 
                                    : (plan['storageLimitGb'] as num).toInt())
                                : null,
                            maxCollaborations: plan['maxCollaborations'] != null
                                ? (plan['maxCollaborations'] is int
                                    ? plan['maxCollaborations']
                                    : (plan['maxCollaborations'] as num).toInt())
                                : null,
                            maxDocumentariesPerMonth: plan['maxDocumentariesPerMonth'] != null
                                ? (plan['maxDocumentariesPerMonth'] is int
                                    ? plan['maxDocumentariesPerMonth']
                                    : (plan['maxDocumentariesPerMonth'] as num).toInt())
                                : null,
                            supportLevel: plan['supportLevel'],
                          ),
                        ),
                  ],
                ),
                // --- Botones ---
                Column(
                  children: [
                    PrimaryButton(
                      text: _isLoadingPaypal ? "Procesando..." : "Suscribirse",
                      color: AppColors.primary2,
                      onPressed: _isLoadingPaypal ? null : _subscribeRecurring,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Omitir por ahora",
                        style: TextStyle(color: Color(0xFFFC7171), fontSize: 15),
                      ),
                    ),
                    const Text(
                      "La suscripción se renueva automáticamente a menos que se desactive la renovación automática 24 horas antes del final del período actual.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}