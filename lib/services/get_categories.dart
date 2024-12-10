import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchCategories() async {
  const String apiUrl = 'http://45.79.205.216:8000/admin/inventory/categories';
  const String username = 'larry.davila';
  const String password = 'Prueba1#';

  try {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // print('Haciendo fetch a: $apiUrl');
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
    );

    // print('Código de estado: ${response.statusCode}');
    // print('Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print('Tipo de dato decodificado: ${data.runtimeType}');
      // print('Contenido decodificado: $data');

      // Validar que la respuesta sea una lista de strings
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
