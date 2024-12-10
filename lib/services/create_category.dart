import 'dart:convert';
import 'package:http/http.dart' as http;

// Post a Category
Future<void> createCategory(String category) async {
  const String username = 'larry.davila';
  const String password = 'Prueba1#';
  const String apiUrl = 'http://45.79.205.216:8000/admin/inventory/categories';

  final Map<String, String> categoryCreated = {
    "name": category
  };

  final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    },
    body: json.encode(categoryCreated),
  );

  if (response.statusCode != 201) {
    print(category);
    throw Exception('Error: ${response.body}');
  }
}
