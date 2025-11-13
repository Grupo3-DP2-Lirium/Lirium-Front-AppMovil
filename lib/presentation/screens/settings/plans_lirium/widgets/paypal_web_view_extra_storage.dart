import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/services/extra_storage_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebViewExtraStorage extends StatefulWidget {
  final String url;
  final String extraPlanId;
  final String frequency;
  final String? subscriptionId;

  const PayPalWebViewExtraStorage({
    super.key,
    required this.url,
    required this.extraPlanId,
    required this.frequency,
    this.subscriptionId,
  });

  @override
  State<PayPalWebViewExtraStorage> createState() => _PayPalWebViewExtraStorageState();
}

class _PayPalWebViewExtraStorageState extends State<PayPalWebViewExtraStorage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  final ExtraStorageService _service = ExtraStorageService();

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
              final uri = Uri.parse(url);
              final subscriptionId = widget.subscriptionId ?? uri.queryParameters['subscription_id'] ?? uri.queryParameters['subscriptionID'];

              if (subscriptionId == null) {
                Navigator.pop(context, {'status': 'error', 'message': 'subscription id missing'});
                return NavigationDecision.prevent;
              }

              // Confirmar suscripción extra con el servicio de ExtraStorage
              try {
                await _service.confirmExtraStorageSubscription(
                  subscriptionId: subscriptionId,
                  extraPlanId: widget.extraPlanId,
                  onLoading: (isLoading) => setState(() => _isLoading = isLoading),
                );

                Navigator.pop(context, {
                  'status': 'success',
                  'subscriptionId': subscriptionId,
                });
              } catch (e) {
                Navigator.pop(context, {'status': 'error', 'message': e.toString()});
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
      appBar: AppBar(title: const Text("Procesando pago Extra Storage")),
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
