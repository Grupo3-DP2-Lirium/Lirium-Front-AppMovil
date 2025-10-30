import 'package:flutter/material.dart';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/paypal_web_view.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/plan_card.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/premium_tab_selector.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/receipt_paypal.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/subscription_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GetPremiumScreen extends StatefulWidget {
  const GetPremiumScreen({super.key});

  @override
  State<GetPremiumScreen> createState() => _GetPremiumScreenState();
}

class _GetPremiumScreenState extends State<GetPremiumScreen> {
  bool isMonthly = true;
  int selectedPlanIndex = 0; // Plan seleccionado por defecto
  bool _isLoadingPlans = false;
  List<Map<String, dynamic>> plans = [];

  Future<void> _subscribe() async {
    if (plans.isEmpty) return; // 🔹 por si no hay planes cargados
    final plan = plans[selectedPlanIndex];

    final double basePrice = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;
    final double planAmountValue = isMonthly ? basePrice : (basePrice * 12 * 0.7);
    final String planAmount = planAmountValue.toStringAsFixed(2);

    try {
      // Crear orden en el backend
      final createOrderResponse = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/paypal/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': planAmount,
          'simulateFail': false,
        }),
      );

      if (createOrderResponse.statusCode != 200) {
        throw Exception('Error creando orden');
      }

      final orderData = jsonDecode(createOrderResponse.body);
      final approvalLink = orderData['approvalLink'];

      // Verificar que exista approvalLink y planId
      final plan = plans[selectedPlanIndex];
      print('El planid es: $plan');
      print('approvalLink: $approvalLink');

      if (approvalLink == null || approvalLink.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar el pago.')),
        );
        return;
      }

      final planId = plan['idPlan'];

      // Abrir WebView para que el usuario apruebe el pago
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

      // Verificar resultado del pago
      if (paymentResult != null &&
          paymentResult is Map<String, dynamic> &&
          paymentResult['status'] == 'success') {
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
  void initState() {
    super.initState();
    _loadPlans();
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
                      ...List.generate(plans.length, (index) {
                        final plan = plans[index];
                        final double basePrice = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;
                        final String currency = plan['currency'] ?? 'USD';

                        // 🔹 Calcular precio según si es mensual o anual
                        final double displayPrice = isMonthly
                            ? basePrice
                            : (basePrice * 12 * 0.7); // 30% de descuento

                        final String priceText =
                            '$currency ${displayPrice.toStringAsFixed(2)}';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PlanCard(
                            title: plan['name'] ?? '',
                            price: priceText,
                            description: plan['description'] ?? '',
                            recommended: index == 0,
                            isSelected: selectedPlanIndex == index,
                            onTap: () {
                              setState(() {
                                selectedPlanIndex = index;
                              });
                            },
                          ),
                        );
                      }),
                  ],
                ),
                // --- Botones ---
                Column(
                  children: [
                    PrimaryButton(
                      text: "Suscribirse",
                      color: AppColors.primary2,
                      onPressed: _subscribe,
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