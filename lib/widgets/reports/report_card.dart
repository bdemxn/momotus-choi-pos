import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:choi_pos/services/reports/get_reports_cashier.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class ReportCards extends StatefulWidget {
  const ReportCards({super.key});

  @override
  State<ReportCards> createState() => _ReportCardsState();
}

class _ReportCardsState extends State<ReportCards> {
  Future<List<dynamic>> reports = ReportServiceCashier.fetchReports();
  List<dynamic> filteredReports = [];
  String selectedFilter = 'Hoy';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAndFilterReports();
  }

  void fetchAndFilterReports() async {
    try {
      final fetchedReports = await reports;
      setState(() {
        filteredReports = applyFilter(fetchedReports, selectedFilter);
      });
    } catch (e) {
      setState(() {
        filteredReports = [];
      });
    }
  }

  List<dynamic> applySearch(List<dynamic> reports, String query) {
    if (query.isEmpty) {
      return reports; // Retorna todos los reportes si no hay búsqueda
    }
    return reports
        .where((report) => (report['id']?['id']?['String'] ?? 'N/A')
            .toLowerCase()
            .contains(query))
        .toList();
  }

  Future<void> exportToCSV(List<dynamic> reports) async {
    try {
      List<List<String>> csvData = [
        [
          'Cajero',
          'Cliente',
          'Fecha',
          'ID Venta',
          'Referencia de Pago',
          'Productos',
          'Promoción',
          'Total Pagado'
        ]
      ];

      csvData.addAll(reports.map((report) {
        final productsNames =
            (report['products'] != null && report['products'] is List<dynamic>)
                ? (report['products'] as List<dynamic>)
                    .map((product) => product.toString())
                    .join(', ')
                : 'Sin productos';

        return [
          (report['cashier'] ?? 'N/A').toString(),
          (report['customer'] ?? 'N/A').toString(),
          (report['date'] ?? 'N/A').toString(),
          (report['id']?['id']?['String'] ?? 'N/A').toString(),
          (report['payment_ref'] ?? 'N/A').toString(),
          productsNames,
          (report['promocode'] ?? 'Ninguno').toString(),
          '\$${report['total_paid'] ?? 0}'
        ];
      }).cast<List<String>>());

      String csv = const ListToCsvConverter().convert(csvData);

      // Guardar en un archivo
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/reportes.csv';
      final file = File(path);
      await file.writeAsString(csv);
    } catch (e) {
      rethrow;
    }
  }

  List<dynamic> applyFilter(List<dynamic> reports, String filter) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd-MM-yy HH:mm'); // Formato correcto

    return reports.where((report) {
      try {
        final reportDate = dateFormat.parse(report['date']);
        switch (filter) {
          case 'Hoy':
            return reportDate.year == now.year &&
                reportDate.month == now.month &&
                reportDate.day == now.day;
          case 'Últimos 7 días':
            return reportDate.isAfter(now.subtract(const Duration(days: 7)));
          case 'Último mes':
            return reportDate.isAfter(now.subtract(const Duration(days: 30)));
          default:
            return true;
        }
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final snapshotData = await reports;
            await exportToCSV(snapshotData);
          },
          icon: const Icon(Icons.download),
          label: const Text('Exportar CSV'),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
          child: DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filtrar por',
              border: OutlineInputBorder(),
            ),
            items: ['Hoy', 'Últimos 7 días', 'Último mes'].map((filter) {
              return DropdownMenuItem<String>(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedFilter = newValue!;
                fetchAndFilterReports();
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: reports,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay reportes disponibles'));
              }

              if (filteredReports.isEmpty) {
                filteredReports = snapshot.data!;
              }

              return Column(children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar por ID de Venta',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                      filteredReports =
                          applySearch(snapshot.data!, searchQuery);
                    });
                  },
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Cajero')),
                      DataColumn(label: Text('Cliente')),
                      DataColumn(label: Text('Fecha')),
                      DataColumn(label: Text('ID Venta')),
                      DataColumn(label: Text('Referencia de Pago')),
                      DataColumn(label: Text('Productos')),
                      DataColumn(label: Text('Promoción')),
                      DataColumn(label: Text('Total Pagado')),
                    ],
                    rows: filteredReports.map((report) {
                      final id = report['id']?['id']?['String'] ?? 'N/A';
                      final productsNames = (report['products_names'] != null &&
                              report['products_names'] is List<dynamic>)
                          ? (report['products_names'] as List<dynamic>)
                              .map((product) => product.toString())
                              .join(', ')
                          : 'Sin productos';

                      return DataRow(
                        cells: [
                          DataCell(Text(report['cashier'] ?? 'N/A')),
                          DataCell(Text(report['customer'] ?? 'N/A')),
                          DataCell(Text(report['date'] ?? 'N/A')),
                          DataCell(Text(id)),
                          DataCell(Text(report['payment_ref'] ?? 'N/A')),
                          DataCell(Text(productsNames)),
                          DataCell(Text(report['promocode'] ?? 'Ninguno')),
                          DataCell(Text('\$${report['total_paid']}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ]);
            },
          ),
        ),
      ],
    );
  }
}
