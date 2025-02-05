import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentServices {
  final List<Map<dynamic, dynamic>> _paymentList = [];
  List<Map<dynamic, dynamic>> get paymentList => _paymentList;

  static const String apiUrl = 'http://216.238.86.5:8000/cashier/payments';

  Future<void> getPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        _paymentList.clear();
        _paymentList.addAll(data.map((item) {
          return {
            "id": item["id"]["id"]["String"], // Extraer ID correctamente
            "client_name": item["client_id"], // El nombre ya viene directo
            "year": item["year"],
            "schedule": item["monthly_id"], // Ajuste para el nuevo formato
            "months": item["months"].isNotEmpty ? item["months"] : [],
          };
        }));
      }
    } catch (e) {
      throw Exception("Error al obtener pagos: $e");
    }
  }

  Future<void> updateMonthly(
      String clientId, int monthsToPay, String paymentMethod) async {
    final monthlyDataToUpdate = {
      "client_id": clientId,
      "months_to_pay": monthsToPay,
      "payment_method": paymentMethod
    };

    print("JSON: $monthlyDataToUpdate");

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
          body: json.encode([monthlyDataToUpdate]));

      if (response.statusCode != 201) {
        throw Exception('Error: ${response.body}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> putPayment(Map<String, bool> paidMonths, String id) async {
    final paidUser = {"months": paidMonths};

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.put(Uri.parse("$apiUrl/$id"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode(paidUser));

      if (response.statusCode == 200) {
        print(response.headers);
      }
    } catch (e) {
      print(e);
    }
  }
}
