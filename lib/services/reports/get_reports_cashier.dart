import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReportServiceCashier {
  static const String apiUrl = 'http://216.238.86.5:8000/cashier/sales';

  static Future<List<dynamic>> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró un token de autenticación.');
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('Error al cargar los reportes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
