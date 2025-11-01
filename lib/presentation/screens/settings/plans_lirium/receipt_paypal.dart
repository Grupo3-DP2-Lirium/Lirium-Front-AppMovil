import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaypalReceiptPopup {
  static void show(BuildContext context, Map<String, dynamic> paymentData) {
    final paypalResponse = paymentData['paypalResponse'] ?? {};
    final orderId = paypalResponse['id'] ?? '—';
    final status = paypalResponse['status'] ?? 'COMPLETED';
    final payer = paypalResponse['payer']?['name']?['given_name'] ?? 'Usuario';
    final amount = paypalResponse['purchase_units']?[0]?['payments']?['captures']?[0]?['amount']?['value'] ?? '0.00';
    final currency = paypalResponse['purchase_units']?[0]?['payments']?['captures']?[0]?['amount']?['currency_code'] ?? 'USD';
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/paypal_logo.png', width: 100),
                const SizedBox(height: 12),
                const Text(
                  'Pago completado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gracias por tu compra, $payer',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Divider(height: 30),
                _infoRow('Monto', '$currency $amount'),
                _infoRow('Estado', status),
                _infoRow('Fecha', date),
                _infoRow('ID de Transacción', orderId),
                const Divider(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0070BA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
