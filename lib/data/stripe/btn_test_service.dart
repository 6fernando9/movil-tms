import 'package:flutter/material.dart';
import 'package:tienda_ecommerce/data/stripe/servicio_api.dart';


class BotonStripePago extends StatelessWidget {
  final String texto;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const BotonStripePago({
    super.key,
    this.texto = "Pagar con Stripe",
    this.onSuccess,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.payment),
      label: Text(texto),
      onPressed: () async {
        try {
          final stripeService = StripeService();
          final intentId = await stripeService.iniciarPago(context: context);

          // Confirmar el pago
          final resultado = await StripeService.confirmarPago(
            context: context,
            paymentIntentId: intentId,
          );

          // Éxito
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("✅ Pago exitoso")));
          if (onSuccess != null) onSuccess!();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ $e")));
          if (onCancel != null) onCancel!();
        }
      },
    );
  }
}
