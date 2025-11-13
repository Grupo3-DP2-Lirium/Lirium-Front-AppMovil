import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebViewScreen extends StatefulWidget {
  final String url;
  final String planId;
  final String frequency;

  const PayPalWebViewScreen({
    super.key,
    required this.url,
    required this.planId,
    required this.frequency,
  });

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  final SubscriptionService _payPalService = SubscriptionService(); // instancia del servicio

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
                final data = await _payPalService.capturePayPalOrder(
                  orderId: orderId,
                  planId: widget.planId,
                  frequency: widget.frequency,
                  simulateFail: false,
                  onLoading: (loading) => setState(() => _isLoading = loading),
                );

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
