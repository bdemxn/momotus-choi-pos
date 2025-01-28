import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<double?> fetchExchangeRate() async {
  const String apiUrl = "https://hexarate.paikama.co/api/rates/latest/USD?target=NIO";

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('data') && data['data'].containsKey('mid')) {
        return data['data']['mid'] as double;
      } else {
        throw const FormatException('Estructura de datos inesperada en la respuesta');
      }
    } else {
      throw HttpException(
          'Error en la solicitud: ${response.statusCode} ${response.reasonPhrase}');
    }
  } on FormatException catch (e) {
    print('Error de formato: $e');
    return null; // O decide si lanzar otra excepción
  } on http.ClientException catch (e) {
    print('Error de red: $e');
    return null;
  } catch (e) {
    print('Error desconocido: $e');
    return null; // O decide si lanzar otra excepción
  }
}

Future<void> saveExchangeRate(double rate) async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().split('T').first; // Solo la fecha (YYYY-MM-DD)
  await prefs.setDouble('exchangeRate', rate);
  await prefs.setString('exchangeRateDate', today);
}

Future<double> loadExchangeRate() async {
  final prefs = await SharedPreferences.getInstance();
  final storedDate = prefs.getString('exchangeRateDate');
  final today = DateTime.now().toIso8601String().split('T').first;

  if (storedDate == today) {
    // Si la fecha coincide, devolver la tasa almacenada
    return prefs.getDouble('exchangeRate') ?? 36.5; // Fallback a 36.5 si no está disponible
  } else {
    // Si la fecha no coincide, forzar un fetch
    return await fetchAndSaveExchangeRate();
  }
}

Future<double> fetchAndSaveExchangeRate() async {
  final rate = await fetchExchangeRate();
  if (rate != null) {
    await saveExchangeRate(rate);
    return rate;
  }
  return 36.5; // Fallback en caso de fallo
}
