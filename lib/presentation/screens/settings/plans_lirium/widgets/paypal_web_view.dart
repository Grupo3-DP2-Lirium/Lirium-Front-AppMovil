import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../config/api_constants.dart';

class PayPalWebViewScreen extends StatefulWidget {
  final String url;
  final int quantity; // cantidad de documentales extra a comprar

  const PayPalWebViewScreen({
    super.key,
    required this.url,
    required this.quantity,
  });

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Habilitar cookies
    final cookieManager = WebViewCookieManager();
    if (kDebugMode) {
      cookieManager.clearCookies();
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (req) async {
            if (req.url.contains('cancel')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            if (req.url.contains('success')) {
              final uri = Uri.parse(req.url);
              final orderId = uri.queryParameters['token'];

              if (orderId == null) {
                Navigator.pop(context, {'status': 'ERROR', 'message': 'orderId not found'});
                return NavigationDecision.prevent;
              }

              try {
                // Usando SubscriptionService
                final subscriptionService = SubscriptionService();
                final data = await subscriptionService.captureExtraDocumentaryOrder(
                  orderId: orderId,
                  quantity: widget.quantity,
                  onLoading: (isLoading) {
                    // Aquí puedes mostrar un loader si quieres
                  },
                );

                // Retorna resultado al frontend
                Navigator.pop(context, data);
              } catch (e) {
                Navigator.pop(context, {'status': 'ERROR', 'message': e.toString()});
              }

              return NavigationDecision.prevent;
            }

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
