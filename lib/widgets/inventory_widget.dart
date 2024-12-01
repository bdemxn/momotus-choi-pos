import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/services/get_inventory.dart';
import 'package:flutter/material.dart';

class InventoryWidget extends StatefulWidget {
  final List<InventoryItem> inventory;
  final String searchQuery;
  final String selectedCategory;
  final void Function(InventoryItem) onAddToCart;
  final void Function(String) onSearchQueryChanged;
  final void Function(String) onCategoryChanged;

  const InventoryWidget({
    super.key,
    required this.inventory,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onAddToCart,
    required this.onSearchQueryChanged,
    required this.onCategoryChanged,
  });

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  final InventoryService _inventoryService = InventoryService();

  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _inventoryService.fetchInventory();
  }

  List<String> get categories {
    return ["Todas", ...widget.inventory.map((item) => item.category).toSet()];
  }

  List<InventoryItem> get filteredInventory {
    return widget.inventory.where((product) {
      final matchesSearch = product.name
              .toLowerCase()
              .contains(widget.searchQuery.toLowerCase()) ||
          product.barCode.contains(widget.searchQuery);
      final matchesCategory = widget.selectedCategory == "Todas" ||
          product.category == widget.selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Inventario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: widget.selectedCategory,
              onChanged: (value) => widget.onCategoryChanged(value!),
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Buscar por código",
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.onSearchQueryChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<void>(
            future: _fetchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                final List<InventoryItem> inventory =
                    _inventoryService.inventory;
                if (inventory.isEmpty) {
                  return const Center(
                      child: Text("No hay artículos en el inventario."));
                }
                return ListView.builder(
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    return ListView.builder(
                      itemCount: filteredInventory.length,
                      itemBuilder: (context, index) {
                        final product = filteredInventory[index];
                        return Card(
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                                "Precio: \$${product.price} | Stock: ${product.quantity}"),
                            trailing: ElevatedButton(
                              onPressed: () => widget.onAddToCart(product),
                              child: const Text("Añadir"),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
