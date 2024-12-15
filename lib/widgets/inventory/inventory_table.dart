import 'package:choi_pos/services/inventory/get_inventory.dart';
import 'package:flutter/material.dart';

class InventoryTable extends StatefulWidget {
  const InventoryTable({super.key});

  @override
  State<InventoryTable> createState() => _InventoryTableState();
}

class _InventoryTableState extends State<InventoryTable> {
  // InventoryService new state
  final InventoryService _inventoryService = InventoryService();

  @override
  void initState() {
    super.initState();
    // fetch:
    _inventoryService.fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _inventoryService.fetchInventory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final inventory = _inventoryService.inventory;

        return Flexible(
          fit: FlexFit.tight,
          flex: 5,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Código de Barras')),
                  DataColumn(label: Text('Categoría')),
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Precio')),
                  DataColumn(label: Text('Cantidad')),
                ],
                rows: inventory
                    .map(
                      (item) => DataRow(cells: [
                        DataCell(Text(item.id)),
                        DataCell(Text(item.barCode)),
                        DataCell(Text(item.category)),
                        DataCell(Text(item.name)),
                        DataCell(Text(item.price.toString())),
                        DataCell(Text(item.quantity.toString())),
                      ]),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
