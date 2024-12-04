import 'dart:convert';
import 'package:http/http.dart' as http;

// Post an user
Future<void> createUser(Map<String, dynamic> inventoryData) async {
  const String username = 'larry.davila';
  const String password = 'Prueba1#';
  const String apiUrl = 'http://45.79.205.216:8000/admin/inventory';

  final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    },
    body: json.encode(inventoryData),
  );

  if (response.statusCode != 201) {
    throw Exception('Error: ${response.body}');
  }
}
