import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerService {
  static const String apiUrl = 'http://localhost:8000/admin/clients';
  static const String username = 'larry.davila';
  static const String password = 'Prueba1#';
  final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Future<void> registerCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
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
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': basicAuth
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
