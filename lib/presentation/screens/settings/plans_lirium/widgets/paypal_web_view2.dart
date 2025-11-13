import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/subscription_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebViewScreen2 extends StatefulWidget {
  final String url;
  final String planId;
  final String frequency;
  final bool isSubscription;
  final String? subscriptionId;

  const PayPalWebViewScreen2({
    super.key,
    required this.url,
    required this.planId,
    required this.frequency,
    this.isSubscription = false,
    this.subscriptionId,
  });

  @override
  State<PayPalWebViewScreen2> createState() => _PayPalWebViewScreenState2();
}

class _PayPalWebViewScreenState2 extends State<PayPalWebViewScreen2> {
  late final WebViewController _controller;
  bool _isLoading = true;

  final SubscriptionService _service = SubscriptionService();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (req) async {
            final url = req.url;

            if (url.contains('cancel')) {
              Navigator.pop(context, {'status': 'canceled'});
              return NavigationDecision.prevent;
            }

            if (url.contains('success')) {
              if (widget.isSubscription) {
                // Suscripción automática
                final uri = Uri.parse(url);
                final subscriptionId = widget.subscriptionId ?? uri.queryParameters['subscription_id'];

                if (subscriptionId == null) {
                  Navigator.pop(context, {'status': 'error', 'message': 'subscription id missing'});
                  return NavigationDecision.prevent;
                }

                // Confirmar y almacenar en backend
                try {
                  await _service.confirmPaypalSubscription(subscriptionId, widget.planId);

                  Navigator.pop(context, {
                    'status': 'success',
                    'subscriptionId': subscriptionId
                  });
                } catch (e) {
                  Navigator.pop(context, {'status': 'error', 'message': e.toString()});
                }

              } else {
                // Pago único (tu lógica original)
                final uri = Uri.parse(url);
                final orderId = uri.queryParameters['token'];

                try {
                  final data = await _service.capturePayPalOrder(
                    orderId: orderId!,
                    planId: widget.planId,
                    frequency: widget.frequency,
                  );
                  Navigator.pop(context, data);
                } catch (e) {
                  Navigator.pop(context, {'status': 'error', 'message': e.toString()});
                }
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
      appBar: AppBar(title: const Text("Procesando con PayPal")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
