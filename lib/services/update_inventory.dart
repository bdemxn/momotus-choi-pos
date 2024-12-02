import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';

class UpdateInventory {
  static const String username = 'larry.davila';
  static const String password = 'Prueba1#';
  static const String baseUrl = 'http://localhost:8000';

  // Actualizar inventario
  static Future<void> updateInventory(List<InventoryItem> cart) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

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
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final serializedProducts = products.map((product) {
      if (product.containsKey('id')) {
        return {
          'id': product['id'], // Verificar que cada producto tenga 'id'
        };
      } else {
        throw Exception('Cada producto debe contener un ID.');
      }
    }).toList();

    final saleReport = {
      'cashier': cashier,
      'customer': customer,
      'payment_ref': paymentRef,
      'products': serializedProducts,
      'promocode': promoCode,
      'total_paid': totalPaid,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cashier/sales'),
      body: jsonEncode(saleReport),
      headers: {'Content-Type': 'application/json', 'Authorization': basicAuth},
    );

    //? Error handler:
    if (response.statusCode != 201) {
      throw Exception('Error enviando el reporte de ventas');
    }
  }

  static Future<void> updateInventoryQuantities(
      List<InventoryItem> cart) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    for (var item in cart) {
      // Obtener la cantidad actual del inventario
      final response = await http.get(
        Uri.parse('$baseUrl/cashier/inventory/${item.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error obteniendo el inventario para ${item.id}');
      }

      // Parsear la cantidad actual
      final currentInventory = jsonDecode(response.body);
      final int currentQuantity = currentInventory['quantity'];

      // Calcular la nueva cantidad
      final int updatedQuantity = currentQuantity - item.quantity;

      // Validar que no quede en negativo
      if (updatedQuantity < 0) {
        throw Exception(
            'Error: La cantidad en el carrito (${item.quantity}) supera la cantidad disponible ($currentQuantity) para el producto ${item.id}');
      }

      // Actualizar la cantidad
      final updateResponse = await http.put(
        Uri.parse('$baseUrl/cashier/inventory/${item.id}'),
        body: jsonEncode({'quantity': updatedQuantity}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (updateResponse.statusCode != 200) {
        throw Exception('Error actualizando el inventario para ${item.id}');
      }
    }
  }
}
