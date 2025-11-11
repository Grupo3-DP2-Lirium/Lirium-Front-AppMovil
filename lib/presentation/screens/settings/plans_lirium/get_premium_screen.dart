import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/storage_service.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/paypal_web_view.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/paypal_web_view2.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/plan_card.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/premium_tab_selector.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/widgets/receipt_paypal.dart';
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

  Future<void> _subscribeJustOneTime() async {
    // No plans loaded
    if (plans.isEmpty) return;

    // Get selected plan
    final plan = plans[selectedPlanIndex];
    final double basePrice = double.tryParse(plan['price'].toString()) ?? 0;
    // Monthly vs yearly (30% discount)
    final double planAmountValue = isMonthly ? basePrice : (basePrice * 12 * 0.7);
    // Format price for PayPal
    final String planAmount = planAmountValue.toStringAsFixed(2);

    try {
      // Create PayPal order
      final createOrderResponse = await subscriptionService.createPayPalOrder(
        amount: double.parse(planAmount),
        simulateFail: false,
        planId: plan['idPlan'].toString(),
        onLoading: (isLoading) {
          setState(() => _isLoadingPaypal = isLoading);
        },
      );

      // Approval URL returned by PayPal
      final approvalLink = createOrderResponse['approvalLink'];

      if (approvalLink.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo iniciar el pago.")),
        );
        return;
      }

      // Subscription plan ID
      final planId = plan['idPlan'];

      // Open PayPal webview for payment approval
      final paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayPalWebViewScreen(
            url: approvalLink,
            planId: planId.toString(),
            frequency: isMonthly ? "MONTHLY" : "YEARLY",
          ),
        ),
      );

      // Check payment result
      if (paymentResult != null && paymentResult is Map<String, dynamic> &&
          paymentResult['status'] == 'success') {
        // Show receipt popup
        PaypalReceiptPopup.show(context, paymentResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pago capturado pero error creando suscripción")),
        );
      }
    } catch (e) {
      print('Error en suscripción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _subscribeRecurring() async {
    if (plans.isEmpty) return;

    final plan = plans[selectedPlanIndex];

    final String paypalPlanId = plan['paypalPlanId']; // esto debe venir de BD
    final String internalPlanId = plan['idPlan']; // ID de tu BD

    try {
      setState(() => _isLoadingPaypal = true);

      final response = await subscriptionService.createPaypalSubscription(
        paypalPlanId: paypalPlanId,
        planId: internalPlanId
      );

      final approvalLink = response['approvalLink'];
      final subscriptionId = response['subscriptionID'];

      if (approvalLink == null || approvalLink.isEmpty) {
        throw Exception("No se recibio approvalLink de PayPal");
      }

      // Abrimos PayPal WebView para que pague
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
        await StorageService.savePlan(plan['name']);

        // Obtener y guardar los permisos actualizados
        final updatedPermissions = await subscriptionService.getPlanPermissions(plan['idPlan']);
        await StorageService.savePermissions(updatedPermissions);

        // Actualizar estado local del widget
        setState(() {
          currentPlan = plan['name'];
        });

        final userPermissions = await StorageService.getPermissions();

        // Imprimir valores actualizados
        print("Plan actualizado: $currentPlan");
        print("Permisos actualizados: $userPermissions");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Suscripción activada exitosamente!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La suscripción no fue completada.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoadingPaypal = false);
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

  Future<void> _loadCurrentPlan() async {
    final plan = await StorageService.getPlan();
    final permissions = await StorageService.getPermissions();

    setState(() {
      currentPlan = plan ?? "FREE";
    });

    print("Plan guardado del usuario: $currentPlan");
    print("Permisos guardados del usuario: $permissions");
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
    _loadCurrentPlan();
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
                        width: 96,
                        height: 96,
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
                        "Desbloquea todo el poder de Lyrium y vive una experiencia única para preservar tu historia",
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
                            // Atributos extra
                            storageLimitGb: plan['storageLimitGb'],
                            maxCollaborations: plan['maxCollaborations'],
                            maxDocumentariesPerMonth: plan['maxDocumentariesPerMonth'],
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