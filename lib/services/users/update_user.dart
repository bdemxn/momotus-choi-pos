import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserService {
  static const String apiUrl = 'http://216.238.86.5:8000/admin/users';

  /// Actualiza un usuario con el ID y los datos proporcionados.
  ///
  /// [id] - ID del usuario a actualizar.
  /// [updatedUserData] - Mapa con los datos actualizados del usuario.
  /// Lanza una excepción si ocurre un error.
   
   
  static Future<void> updateUser(
      String id, Map<String, dynamic> updatedUserData) async {
    try {
      // Obtener el token de autenticación desde las preferencias compartidas
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      // Realizar la solicitud HTTP PUT
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedUserData),
      );

      print(updatedUserData);

      // Verificar el estado de la respuesta
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el usuario: ${response.body}');
      }
    } catch (e) {
      print('Error al actualizar usuario: $e');
      rethrow;
    }
  }
}
