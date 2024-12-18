import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportService {
  static const String username = 'larry.davila';
  static const String password = 'Prueba1#';
  static const String apiUrl = 'http://45.79.205.216:8000/cashier/sales';

  static Future<List<dynamic>> fetchReports() async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
        
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth
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
