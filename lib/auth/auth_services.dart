import 'dart:async';
import 'dart:convert';
import 'package:choi_pos/models/user_pos_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://216.238.86.5:9000';
  Timer? _tokenRefreshTimer;

  void startTokenRefreshTimer() {
    const refreshInterval = Duration(minutes: 5); // Intervalo de verificación
    _tokenRefreshTimer = Timer.periodic(refreshInterval, (Timer timer) async {
      await _checkAndRefreshToken();
    });
  }

  void stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  Future<void> _checkAndRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiration = prefs.getString('tokenExpiration');

    if (expiration != null) {
      final now = DateTime.now().toUtc();
      final expirationDate = DateTime.parse(expiration).toUtc();

      if (expirationDate.isBefore(now.add(const Duration(minutes: 5)))) {
        await refreshToken();
      }
    }
  }

  Future<UserModel?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/token');
    final body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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
        await prefs.setString('fullname', user.fullname);
        await prefs.setString('tokenExpiration', user.expiresAt.toString());

        startTokenRefreshTimer();

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
    await prefs.remove('fullname');
    await prefs.remove('tokenExpiration');

    stopTokenRefreshTimer();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final expiration = prefs.getString('tokenExpiration');

    if (token != null && expiration != null) {
      final now = DateTime.now().toUtc();
      final expirationDate = DateTime.parse(expiration).toUtc();

      if (expirationDate.isBefore(now.add(const Duration(minutes: 5)))) {
        return await refreshToken();
      }
    }

    return token;
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('authToken');

    if (currentToken == null) {
      throw Exception("No hay token disponible para refrescar.");
    }

    final url = Uri.parse(
        '$_baseUrl/refresh-token'); // Endpoint para refrescar el token
    final body = {
      'access_token': currentToken,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['access_token'] == null) {
          throw Exception("El servidor no devolvió un nuevo token.");
        }

        final newToken = data['access_token'];
        final newExpiration = data['expires_at']; // Nueva fecha de expiración

        await prefs.setString('authToken', newToken);
        await prefs.setString('tokenExpiration', newExpiration);

        return newToken;
      } else {
        print('Error al refrescar el token: ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Error al refrescar el token: $e');
    }
  }
}
