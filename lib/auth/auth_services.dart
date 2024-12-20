import 'dart:convert';
import 'package:choi_pos/models/user_pos_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://45.79.205.216:9000';

  Future<UserModel?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/token');
    final body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['access_token'] == null) {
          throw Exception("El servidor no devolvió un token.");
        }

        final user = UserModel.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', user.token);
        await prefs.setString('userRole', user.role);
        await prefs.setString('username', username);

        return user;
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Error en la autenticación: $e');
    }
  }

  Future<void> logoutAuthService() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
  await prefs.remove('userRole');
}


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}
