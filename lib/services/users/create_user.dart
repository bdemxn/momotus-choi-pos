import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Post an inventory's item
Future<void> createUser(Map<String, dynamic> userData) async {
  const String apiUrl = 'http://45.79.205.216:8000/admin/users';

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  if (token == null) {
    throw Exception('No se encontró un token de autenticación.');
  }

  print(userData);

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(userData),
  );

  if (response.statusCode != 201) {
    throw Exception('Error: ${response.body}');
  }
}
