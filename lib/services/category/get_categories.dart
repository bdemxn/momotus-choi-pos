import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> fetchCategories() async {
  const String apiUrl = 'http://45.79.205.216:8000/admin/inventory/categories';

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  if (token == null) {
    throw Exception('No se encontró un token de autenticación.');
  }

  try {

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data is List && data.every((item) => item is String)) {
        return List<String>.from(data);
      } else {
        throw Exception('Formato inesperado de la respuesta JSON');
      }
    } else {
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    }
  } catch (e) {
    // print('Excepción durante el fetch: $e');
    throw Exception('Error al hacer fetch: $e');
  }
}
