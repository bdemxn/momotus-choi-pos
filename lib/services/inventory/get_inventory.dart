import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';

class InventoryService {
  final List<InventoryItem> _inventory = [];

  List<InventoryItem> get inventory => _inventory;

  // Obtener categorías únicas
  List<String> get categories {
    final Set<String> categorySet = _inventory.map((item) => item.category).toSet();
    return ["Todas", ...categorySet]; // Añadimos "Todas" como opción inicial.
  }

  // Filtrar inventario por texto y categoría
  List<InventoryItem> filteredInventory(String search, [String? category]) {
    return _inventory.where((item) {
      final matchesSearch = search.isEmpty || item.barCode.contains(search);
      final matchesCategory = category == null || category == "Todas" || item.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> fetchInventory() async {
    const String username = 'larry.davila';
    const String password = 'Prueba1#';
    const String apiUrl = 'http://45.79.205.216:8000/admin/inventory';

    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      });

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
