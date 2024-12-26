import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:choi_pos/models/inventory_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryService {
  final List<InventoryItem> _inventory = [];

  List<InventoryItem> get inventory => _inventory;

  // Obtener categorías únicas
  List<String> get categories {
    final Set<String> categorySet =
        _inventory.map((item) => item.category).toSet();
    return ["Todas", ...categorySet]; // Añadimos "Todas" como opción inicial.
  }

  // Filtrar inventario por texto y categoría
  List<InventoryItem> filteredInventory(String search, [String? category]) {
    return _inventory.where((item) {
      final matchesSearch = search.isEmpty || item.barCode.contains(search);
      final matchesCategory =
          category == null || category == "Todas" || item.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> fetchInventory() async {
    const String apiUrl = 'http://45.79.205.216:8000/admin/inventory';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        _inventory.clear();
        _inventory.addAll(data.map((item) => InventoryItem.fromJson(item)));
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer fetch: $e');
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');
    const String apiUrl = 'http://45.79.205.216:8000/admin/inventory';

    if (token == null) throw Exception('No se encontró un token de autenticación.');

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(item.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al actualizar el artículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el artículo: $e');
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró un token de autenticación.');
    }
    const String apiUrl = 'http://45.79.205.216:8000/admin/inventory';

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Eliminar localmente el elemento del inventario
        _inventory.removeWhere((item) => item.id == id);
      } else {
        throw Exception(
            'Error al eliminar el artículo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar el artículo: $e');
    }
  }
}
