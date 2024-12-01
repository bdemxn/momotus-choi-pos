import 'package:flutter/material.dart';
import 'package:choi_pos/models/inventory_item.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;

  const InventoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Categoría: ${item.category}"),
            Text("Código de barras: ${item.barCode}"),
            Text("Cantidad: ${item.quantity}"),
            Text("Precio: \$${item.price.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
