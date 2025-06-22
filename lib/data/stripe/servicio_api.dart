import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tienda_ecommerce/data/stripe/servicio_data.dart';
import 'package:tienda_ecommerce/providers/auth_provider.dart';
import 'package:tienda_ecommerce/services/api_service.dart';

class StripeService {
  static String? _ultimoPaymentIntent;

  static String? get ultimoPaymentIntent => _ultimoPaymentIntent;

  static void setPaymentIntent(String id) {
    _ultimoPaymentIntent = id;
  }

  static void limpiarPaymentIntent() {
    _ultimoPaymentIntent = null;
  }

  Future<String> iniciarPago({required BuildContext context}) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      print(token);
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/stripe/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        //deberia mandarse el objeto del storage
        body: jsonEncode(ServicioTest.jsonService),
      );
      
      if (response.statusCode != 200) {
          print("❌ Status code: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        final data = jsonDecode(response.body);
        throw Exception(
          "Error inesperado: ${data['message'] ?? 'Respuesta inválida'}",
        );
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['client_secret'];
      final paymentIntentId = data['payment_intent_id'];

      print("PAYMENT $paymentIntentId");
      setPaymentIntent(paymentIntentId);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          allowsDelayedPaymentMethods: true,
           merchantDisplayName:
              "Mudanzas Go", // ⚠️ requerido en algunas versiones
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return paymentIntentId;
    } on StripeException {
      final id = StripeService.ultimoPaymentIntent;
      if (id != null) {
        await cancelarPaymentIntentDesdeBackend(
          context: context,
          paymentIntentId: id,
        );
        limpiarPaymentIntent();
      }
      throw Exception("El pago fue cancelado");
    } catch (e) {
      throw Exception("Error al procesar el pago: $e");
    }
  }

  Future<void> cancelarPaymentIntentDesdeBackend({
    required BuildContext context,
    required String paymentIntentId,
  }) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    await http.post(
      Uri.parse('${ApiService.baseUrl}/stripe/cancel-payment-intent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"payment_intent_id": paymentIntentId}),
    );
  }

  static Future<Map<String, dynamic>> confirmarPago({
    required BuildContext context,
    required String paymentIntentId,
  }) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    // Clonar el JSON e incluir el payment_intent_id
    final Map<String, dynamic> servicioConPago = Map.from(
      ServicioTest.jsonService,
    )..['payment_intent_id'] = paymentIntentId;

    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/stripe/confirm-payment-intent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(servicioConPago),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(
        "Error al confirmar el pago: ${data['message'] ?? response.body}",
      );
    }
  }
}
