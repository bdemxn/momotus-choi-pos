import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentServices {
  final List<Map<dynamic, dynamic>> _paymentList = [];
  List<Map<dynamic, dynamic>> get paymentList => _paymentList;

  static const String apiUrl = 'http://45.79.205.216:8000/cashier/payments';

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

      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        _paymentList.clear();
        _paymentList.addAll(data.map((item) => item as Map<dynamic, dynamic>));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> putPayment(Map<String, bool> paidMonths, String id) async {

    final paidUser = {
      "months": paidMonths 
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.put(
        Uri.parse("$apiUrl/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(paidUser)
      );

      if (response.statusCode == 200) {
        print(response.headers);
      }

    } catch (e) {
      print(e);
    }
  }
}
