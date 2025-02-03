import 'package:choi_pos/services/monthly/monthly_services.dart';
import 'package:flutter/material.dart';

class MonthlyTable extends StatefulWidget {
  const MonthlyTable({super.key});

  @override
  State<MonthlyTable> createState() => _MonthlyTableState();
}

class _MonthlyTableState extends State<MonthlyTable> {
  final MonthlyServices _monthlyService = MonthlyServices();

  @override
  void initState() {
    super.initState();
    _monthlyService.fetchMonthly();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _monthlyService.fetchMonthly(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final bundles = _monthlyService.monthlyList;

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
                  DataColumn(label: Text('Precio')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: bundles
                    .map(
                      (bundle) => DataRow(cells: [
                        DataCell(Text((bundle["id"]
                                    as Map<String, dynamic>?)?["id"]?["String"]
                                ?.toString() ??
                            "N/A")),
                        DataCell(Text(bundle["name"])),
                        DataCell(
                            Text(bundle["price"].toStringAsFixed(2))),
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
                                            '¿Estás seguro de que quieres eliminar "${bundle["name"]}"?'),
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
