import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';

class UpdateInventory {
  static const String username = 'larry.davila';
  static const String password = 'Prueba1#';
  static const String baseUrl = 'http://localhost:8000';

  // Actualizar inventario
  static Future<void> updateInventory(List<InventoryItem> cart) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    for (var item in cart) {
      final response = await http.put(
        Uri.parse('$baseUrl/cashier/inventory/${item.id}'),
        body: jsonEncode({'quantity': item.quantity}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error actualizando el inventario para ${item.id}');
      }
    }
  }

  // Enviar reporte de ventas
  static Future<void> postSalesReport({
    required String cashier,
    required String? customer,
    required String paymentRef,
    required List<Map<String, dynamic>> products,
    required String promoCode,
    required double totalPaid,
  }) async {
    final saleReport = {
      'cashier': cashier,
      'customer': customer,
      'payment_ref': paymentRef,
      'products': products,
      'promocode': promoCode,
      'total_paid': totalPaid,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cashier/sales-report'),
      body: jsonEncode(saleReport),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Error enviando el reporte de ventas');
    }
  }
}
