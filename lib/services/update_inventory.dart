import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';

class UpdateInventory {
  static const String username = 'larry.davila';
  static const String password = 'Prueba1#';
  static const String baseUrl = 'http://localhost:8000';

  // Método para actualizar el inventario
  static Future<void> updateInventory(List<Map<String, dynamic>> cart) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    for (var item in cart) {
      // Obtener cantidad actual del inventario
      final response = await http.get(
        Uri.parse('$baseUrl/cashier/inventory/${item['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error obteniendo inventario para ${item['name']}');
      }

      final currentInventory = jsonDecode(response.body);
      final int currentQuantity = currentInventory['quantity'];

      // Calcular la nueva cantidad
      final num updatedQuantity = currentQuantity - item['quantity'];

      if (updatedQuantity < 0) {
        throw Exception(
            'Stock insuficiente: ${item['name']} (Disponible: $currentQuantity, Requerido: ${item['quantity']})');
      }

      // Hacer PUT para actualizar cantidad
      final updateResponse = await http.put(
        Uri.parse('$baseUrl/cashier/inventory/${item['id']}'),
        body: jsonEncode({'quantity': updatedQuantity}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (updateResponse.statusCode != 200) {
        throw Exception(
            'Error actualizando inventario para ${item['name']}.');
      }
    }
  }

  // Método para enviar reporte de ventas
  static Future<void> postSalesReport({
    required String cashier,
    required String? customer,
    required String paymentRef,
    required List<Map<String, dynamic>> cart,
    required String promoCode,
    required double totalPaid,
  }) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Serializar los productos del carrito
    final products = cart
        .map((item) => {'id': item['id'], 'quantity': item['quantity']})
        .toList();

    final saleReport = {
      'cashier': cashier,
      'customer': customer,
      'payment_ref': paymentRef,
      'products': products,
      'promocode': promoCode,
      'total_paid': totalPaid,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cashier/sales'),
      body: jsonEncode(saleReport),
      headers: {'Content-Type': 'application/json', 'Authorization': basicAuth},
    );

    if (response.statusCode != 201) {
      throw Exception('Error enviando el reporte de ventas.');
    }
  }
}
