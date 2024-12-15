import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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
