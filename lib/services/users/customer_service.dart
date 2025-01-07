import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  static const String apiUrl = 'http://45.79.205.216:8000/admin/clients';

  Future<void> registerCustomer(Map<String, dynamic> customerData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

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

  Future<void> updatedCustomer(Map<String, dynamic> customerData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final Map<String, dynamic> updatedCustomerData = {
        "id": customerData['id'],
        "fullname": customerData['fullname'],
        "is_minor": customerData['is_minor'],
        "phone": customerData['phone'],
        "email": customerData['email'],
        "is_preferred": customerData['is_preferred'],
        "monthly_pay_ref": customerData['monthly_pay_ref'],
        "schedule": customerData['schedule'],
        "times": customerData['times']
      };

      final response = await http.put(
        Uri.parse("$apiUrl/${customerData['id'].substring(8)}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(updatedCustomerData),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el cliente: ${response.body}');
      }
    } catch (e) {
      throw Error();
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Error al obtener clientes: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al eliminar cliente: $e');
      rethrow;
    }
  }
}
