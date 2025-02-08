import 'package:choi_pos/services/monthly/monthly_services.dart';
import 'package:flutter/material.dart';

class MonthlyTable extends StatefulWidget {
  const MonthlyTable({super.key});

  @override
  State<MonthlyTable> createState() => _MonthlyTableState();
}

class _MonthlyTableState extends State<MonthlyTable> {
  final MonthlyServices _monthlyService = MonthlyServices();
  List<Map<dynamic, dynamic>> monthlyList = [];

  @override
  void initState() {
    super.initState();
    _loadMonthly();
  }

  void _loadMonthly() async {
    final data = await _monthlyService.fetchMonthly();
    setState(() {
      monthlyList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return monthlyList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Flexible(
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
                    DataColumn(label: Text('Descuento Preferencial')), // Nueva columna
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: monthlyList
                      .map(
                        (monthly) => DataRow(cells: [
                          DataCell(Text(monthly["id"])), // ID
                          DataCell(Text(monthly["name"])), // Nombre
                          DataCell(Text("\$${monthly["price"]}")), // Precio
                          DataCell(Text("${monthly["discount_preferred"]}%")), // Descuento Preferencial
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _monthlyService.deleteMonthly(monthly["id"]),
                          )),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ),
          );
  }
}
