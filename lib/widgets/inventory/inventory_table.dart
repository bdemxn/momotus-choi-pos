import 'package:choi_pos/services/inventory/get_inventory.dart';
import 'package:choi_pos/widgets/inventory/inventory_edit_form.dart';
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
                  DataColumn(label: Text('Acciones')), // Nueva columna
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
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InventoryEditFormWidget(item: item),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Confirmar Eliminación'),
                                        content: Text(
                                            '¿Estás seguro de que quieres eliminar "${item.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm ?? false) {
                                    await _inventoryService
                                        .deleteInventoryItem(item.id);
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
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
