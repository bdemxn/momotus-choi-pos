import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> createInventoryItemCashier(
    Map<String, dynamic> inventoryData) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  if (token == null) {
    throw Exception('No se encontró un token de autenticación.');
  }
  const String apiUrl = 'http://216.238.86.5:8000/cashier/inventory';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(inventoryData),
  );

  if (response.statusCode != 201) {
    throw Exception('Error: ${response.body}');
  }
}

Future<void> updateRetail(int quantity) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  if (token == null) {
    throw Exception('No se encontró un token de autenticación.');
  }
  const String apiUrl = 'http://216.238.86.5:8000/cashier/inventory';

  final response = await http.put(Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({"quantity": quantity}));

  if (response.statusCode != 201) {
    throw Exception('Error: ${response.body}');
  }
}
