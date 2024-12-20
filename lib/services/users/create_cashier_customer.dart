import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CashierCustomerService {
  static const String apiUrl = 'http://45.79.205.216:8000/cashier/clients';

  Future<void> registerCustomer(Map<String, dynamic> customerData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró un token de autenticación.');
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(customerData),
      );

      if (response.statusCode != 201) {
        throw Exception('Error al registrar cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al registrar cliente: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró un token de autenticación.');
    }

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Error al obtener clientes: ${response.body}');
      }
    } catch (e) {
      print('Error al obtener clientes: $e');
      rethrow;
    }
  }
}
