import 'dart:convert';
import 'package:choi_pos/models/user.dart';
import 'package:http/http.dart' as http;

class GetUsersService {
  final List<User> _userList = [];

  List<User> get userList => _userList;

  Future<void> fetchUsers() async {
    const String username = 'larry.davila';
    const String password = 'Prueba1#';
    const String apiUrl = 'http://45.79.205.216:8000/admin/users';

    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        _userList.clear();
        _userList.addAll(data.map((item) => User.fromJson(item)));
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer fetch: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    const String username = 'larry.davila';
    const String password = 'Prueba1#';
    const String apiUrl = 'http://45.79.205.216:8000/admin/users';

    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar usuario: ${response.body}');
      }
    } catch (e) {
      print('Error al eliminar usuario: $e');
      rethrow;
    }
  }
}
