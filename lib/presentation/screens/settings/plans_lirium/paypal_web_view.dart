import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebViewScreen extends StatefulWidget {
  final String url;

  const PayPalWebViewScreen({super.key, required this.url});

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (req) async {
            // ✅ Si el usuario cancela
            if (req.url.contains('cancel')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            // ✅ Si se detecta éxito
            if (req.url.contains('success')) {
              final uri = Uri.parse(req.url);
              final orderId = uri.queryParameters['token']; // orderId de PayPal

              // Captura el pago
              try {
                await http.post(
                  Uri.parse('${ApiConstants.baseUrl}/paypal/capture-order'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'orderId': orderId}),
                );
              } catch (_) {}

              // 🔹 Cierra el WebView y notifica éxito
              Navigator.pop(context, true);

              // 🚫 Evita que siga navegando a la página de PayPal
              return NavigationDecision.prevent;
            }

            // Navegación normal
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago con PayPal')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
