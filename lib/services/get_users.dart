import 'dart:convert';
import 'package:choi_pos/models/user.dart';
import 'package:http/http.dart' as http;

class GetUsersService {
  final List<User> _userList = [];

  List<User> get userList => _userList;

  Future<void> fetchUsers() async {
    const String username = 'kevin.bonilla';
    const String password = 'caca1234';
    const String apiUrl = 'https://localhost/admin/users';

    try {
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode == 200) {

        final List<dynamic> data = json.decode(response.body);

        _userList.clear();
        _userList.addAll(data.map((item) => User.fromJson(item)));
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer fetch: $e');
    }
  }
}
