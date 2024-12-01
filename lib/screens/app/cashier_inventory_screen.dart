import 'package:choi_pos/services/get_inventory.dart';
import 'package:flutter/material.dart';
import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/widgets/inventory_card.dart';

class CashierInventoryScreen extends StatefulWidget {
  const CashierInventoryScreen({super.key});

  @override
  State<CashierInventoryScreen> createState() => _CashierInventoryScreenState();
}

class _CashierInventoryScreenState extends State<CashierInventoryScreen> {
  final InventoryService _inventoryService = InventoryService();

  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _inventoryService.fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
      ),
      body: FutureBuilder<void>(
        future: _fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final List<InventoryItem> inventory = _inventoryService.inventory;
            if (inventory.isEmpty) {
              return const Center(child: Text("No hay artículos en el inventario."));
            }
            return ListView.builder(
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                return InventoryCard(item: inventory[index]);
              },
            );
          }
        },
      ),
    );
  }
}
