import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MonthlyServices {
  static String apiUrl = 'http://216.238.86.5:8000/admin/monthly';

  final List<Map<dynamic, dynamic>> _monthlyList = [];

  List<Map<dynamic, dynamic>> get monthlyList => _monthlyList;

  Future<void> createMonthly(Map<String, dynamic> monthlyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(monthlyData));

      if (response.statusCode != 201) {
        throw Exception('Error: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<Map>> fetchMonthly() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró un token de autenticación.');
    }

    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print("Mensualidades obtenidas: $responseData");

      // Convertir los datos y actualizar la lista
      _monthlyList.clear();
      _monthlyList.addAll(responseData.map((item) => {
            "id": "${item["id"]["tb"]}:${item["id"]["id"]["String"]}",  // ID correcto
            "name": item["name"],             // Nombre de la mensualidad
            "price": item["price"],           // Precio
            "discount_preferred": item["discount_preferred"], // Descuento Preferencial
          }));

      return _monthlyList;
    } else {
      throw Exception('Error al obtener mensualidades: ${response.body}');
    }
  } catch (error) {
    throw Exception(error);
  }
  }
}
