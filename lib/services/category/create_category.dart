import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Post a Category
Future<void> createCategory(String category) async {
  const String apiUrl = 'http://216.238.86.5:8000/admin/inventory/categories';
  
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  if (token == null) {
    throw Exception('No se encontró un token de autenticación.');
  }

  final Map<String, String> categoryCreated = {
    "name": category
  };

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(categoryCreated),
  );

  if (response.statusCode != 201) {
    print(category);
    throw Exception('Error: ${response.body}');
  }
}
