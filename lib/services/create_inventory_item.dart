import 'dart:convert';
import 'package:http/http.dart' as http;

// Post an inventory's item
Future<void> createInventoryItem(Map<String, dynamic> inventoryData) async {
  const String username = 'kevin.bonilla';
  const String password = 'caca1234';
  const String apiUrl = 'https://localhost/admin/inventory';

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
