import 'package:choi_pos/models/inventory_item.dart';
import 'package:flutter/material.dart';

class InventoryWidget extends StatelessWidget {
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

  List<String> get categories {
    return ["Todas", ...inventory.map((item) => item.category).toSet()];
  }

  List<InventoryItem> get filteredInventory {
    return inventory.where((product) {
      final matchesSearch = product.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          product.barCode.contains(searchQuery);
      final matchesCategory =
          selectedCategory == "Todas" || product.category == selectedCategory;
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
              value: selectedCategory,
              onChanged: (value) => onCategoryChanged(value!),
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
                onChanged: onSearchQueryChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredInventory.length,
            itemBuilder: (context, index) {
              final product = filteredInventory[index];
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      "Precio: \$${product.price} | Stock: ${product.quantity}"),
                  trailing: ElevatedButton(
                    onPressed: () => onAddToCart(product),
                    child: const Text("Añadir"),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
