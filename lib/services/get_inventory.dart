import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';

class InventoryService {
  final List<InventoryItem> _inventory = [];

  List<InventoryItem> get inventory => _inventory;

  Future<void> fetchInventory() async {
    const String username = 'kevin.bonilla';
    const String password = 'caca1234';
    const String apiUrl = 'https://localhost/admin/inventory';

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

        _inventory.clear();
        _inventory.addAll(data.map((item) => InventoryItem.fromJson(item)));
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer fetch: $e');
    }
  }
}