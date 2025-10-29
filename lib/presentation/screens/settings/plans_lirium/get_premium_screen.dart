import 'package:flutter/material.dart';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:flutter_frontend/presentation/components/buttons/primary_button.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/paypal_web_view.dart';
import 'package:flutter_frontend/presentation/screens/settings/plans_lirium/premium_tab_selector.dart';
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

  Future<void> _subscribe() async {
    final plan = plans[selectedPlanIndex];
    final planAmount = isMonthly
        ? plan['monthly']!.split('USD ').last.replaceAll(RegExp(r'[^\d.]'), '')
        : plan['annual']!.split('USD ').last.replaceAll(RegExp(r'[^\d.]'), '');

    try {
      // 1️⃣ Crear orden en tu backend
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

      if (approvalLink == null || approvalLink.isEmpty) {
        throw Exception('No se obtuvo approvalLink de PayPal');
      }

      // 2️⃣ Abrir WebView para que el usuario apruebe el pago
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayPalWebViewScreen(url: approvalLink),
        ),
      );

      // 3️⃣ Resultado del pago
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pago completado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Pago cancelado o fallido')),
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
                    ...List.generate(plans.length, (index) {
                      final plan = plans[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: planCard(
                          title: plan['title']!,
                          subtitle: isMonthly ? plan['monthly']! : plan['annual']!,
                          recommended: plan['recommended']!,
                          isSelected: selectedPlanIndex == index,
                          onTap: () {
                            setState(() {
                              selectedPlanIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
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

  List<Map<String, dynamic>> plans = [
    {
      'title': 'Básico (100 GB)',
      'monthly': '7 días gratis - Luego USD 9.99',
      'annual': '7 días gratis - Luego USD 99.99',
      'recommended': true,
    },
    {
      'title': 'Standard (200 GB)',
      'monthly': '7 días gratis - Luego USD 15.00',
      'annual': '7 días gratis - Luego USD 150.00',
      'recommended': false,
    },
    {
      'title': 'Premium (1 TB)',
      'monthly': '7 días gratis - Luego USD 22.00',
      'annual': '7 días gratis - Luego USD 220.00',
      'recommended': false,
    },
  ];

  Widget planCard({
    required String title,
    required String subtitle,
    required bool recommended,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF20242B) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF303742),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                if (recommended)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC7171),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Recomendado",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF303742),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}