import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CashierRetail extends StatefulWidget {
  const CashierRetail({super.key});

  @override
  _CashierRetailState createState() => _CashierRetailState();
}

class _CashierRetailState extends State<CashierRetail> {
  final List<InventoryItem> _inventory = [];
  List<InventoryItem> _filteredInventory = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    const String apiUrl = 'http://216.238.86.5:8000/admin/inventory';

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

        setState(() {
          _inventory.clear();
          _inventory.addAll(data.map((item) => InventoryItem.fromJson(item)));
          _filteredInventory = List.from(_inventory);
        });
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer fetch: $e');
    }
  }

  void _filterInventory(String query) {
    setState(() {
      _filteredInventory = _inventory
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.barCode.contains(query))
          .toList();
    });
  }

  Future<void> _showRestockDialog(InventoryItem item) async {
    final TextEditingController _quantityController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Re-stock: ${item.name}'),
          content: TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                final int quantity =
                    int.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  await updateRetail(item.id, quantity);
                  Navigator.of(context).pop();
                  fetchInventory(); // Refrescar la lista después de actualizar
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La cantidad debe ser mayor a 0')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRetail(String itemId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró un token de autenticación.');
    }
    const String apiUrl = 'http://216.238.86.5:8000/cashier/inventory';

    final response = await http.put(Uri.parse("$apiUrl/$itemId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"quantity": quantity}));

    if (response.statusCode != 201) {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o código de barras',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterInventory,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredInventory.length,
              itemBuilder: (context, index) {
                final item = _filteredInventory[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle:
                      Text('Código: ${item.barCode} - Stock: ${item.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () => _showRestockDialog(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final double price;
  final String barCode;
  final int quantity;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.barCode,
    required this.quantity,
    required this.category,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      barCode: json['bar_code'],
      quantity: json['quantity'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'barCode': barCode,
      'quantity': quantity,
      'category': category,
    };
  }
}
