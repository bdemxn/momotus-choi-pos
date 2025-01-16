import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TournamentServices {
  static const String apiUrl = "http://216.238.86.5:8000/admin/exams";
  final List<Map<String, dynamic>> _tournamentList = [];
  List<Map<String, dynamic>> get tournamentList => _tournamentList;

  Future<void> getTournaments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _tournamentList.clear();
        _tournamentList.addAll(data.map((item) => item as Map<String, dynamic>));
      }
      
      print(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createTournament(String name, String price) async {
    final Map<String, dynamic> newTournament = {
      "name": name,
      "price": double.parse(price)
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(newTournament));

      print(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteTournament(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.delete(
        Uri.parse("$apiUrl/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }
}
