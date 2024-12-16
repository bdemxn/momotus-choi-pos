import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';

class UpdateInventory {
  static const String username = 'larry.davila';
  static const String password = 'Prueba1#';
  static const String baseUrl = 'http://45.79.205.216:8000';

  static Future<void> postSales(List<InventoryItem> cart) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Crear lista de mapas con id y cantidad
    final List<Map<String, dynamic>> salesData = cart.map((item) {
      return {
        'id': item.id,
        'qnt': item.quantity,
      };
    }).toList();

    print(salesData);

    // Realizar el POST
    final response = await http.post(
      Uri.parse('$baseUrl/cashier/update_inventory'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
      body: jsonEncode(salesData),
    );

    // Manejo de la respuesta
    if (response.statusCode != 200) {
      throw Exception('Error al enviar los datos de venta: ${response.body}');
    }

    // Realización de post a facturas
    final otherResponse = await http.post(
      Uri.parse('$baseUrl/cashier/receipt'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
      body: jsonEncode(salesData),
    );

    if (otherResponse.statusCode == 200 ) {
      throw Exception('Error al enviar los datos de venta: ${response.body}');
    }
  }

  // Método para actualizar el inventario
  static Future<void> updateInventory(List<InventoryItem> cart) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    for (var item in cart) {
      // Obtener cantidad actual del inventario
      final response = await http.get(
        Uri.parse('$baseUrl/cashier/inventory/${item.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error obteniendo inventario para ${item.name}');
      }

      final currentInventory = jsonDecode(response.body);
      final int currentQuantity = currentInventory['quantity'];

      // Calcular la nueva cantidad
      final num updatedQuantity = currentQuantity - item.quantity;

      if (updatedQuantity < 0) {
        throw Exception(
            'Stock insuficiente: ${item.name} (Disponible: $currentQuantity, Requerido: ${item.quantity})');
      }

      // Hacer PUT para actualizar cantidad
      final updateResponse = await http.put(
        Uri.parse('$baseUrl/cashier/inventory/${item.id}'),
        body: jsonEncode({'quantity': updatedQuantity}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
        },
      );

      if (updateResponse.statusCode != 200) {
        throw Exception('Error actualizando inventario para ${item.name}.');
      }
    }
  }

  // Método para enviar reporte de ventas
  static Future<void> postSalesReport({
    required String cashier,
    required String? customer,
    required String? type,
    required String? currency,
    required String paymentRef,
    required List<Map<String, dynamic>> cart,
    required String promoCode,
    required double totalPaid,
    required num change
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
      'type_': type,
      'currency': currency,
      'change': change
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cashier/sales'),
      body: jsonEncode(saleReport),
      headers: {'Content-Type': 'application/json', 'Authorization': basicAuth},
    );

    print(jsonEncode(saleReport));

    if (response.statusCode != 201) {
      throw Exception('Error enviando el reporte de ventas.');
    }
  }
}
