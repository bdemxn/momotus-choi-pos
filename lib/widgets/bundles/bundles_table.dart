import 'package:flutter/material.dart';
import 'package:choi_pos/services/bundles/get_bundles.dart';

class BundlesTable extends StatefulWidget {
  const BundlesTable({super.key});

  @override
  State<BundlesTable> createState() => _BundlesTableState();
}

class _BundlesTableState extends State<BundlesTable> {
  final BundleService _bundleService = BundleService();

  @override
  void initState() {
    super.initState();
    _bundleService.fetchBundles();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bundleService.fetchBundles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final bundles = _bundleService.bundles;

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
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Precio Total')),
                  DataColumn(label: Text('Productos')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: bundles
                    .map(
                      (bundle) => DataRow(cells: [
                        DataCell(Text(bundle.id)),
                        DataCell(Text(bundle.name)),
                        DataCell(Text(bundle.totalPrice.toStringAsFixed(2))),
                        DataCell(Text(
                          bundle.products
                              .map((product) =>
                                  '${product.id} (${product.quantity})')
                              .join(', '),
                        )),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Navegación o acción para editar
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
                                            '¿Estás seguro de que quieres eliminar "${bundle.name}"?'),
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
                                    // Implementar eliminación
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