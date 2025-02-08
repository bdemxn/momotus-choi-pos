import 'dart:io';
import 'package:choi_pos/services/reports/get_reports.dart';
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
  final ReportService _reportService = ReportService();
  List<dynamic> filteredReports = [];
  String selectedFilter = 'Hoy';
  String searchQuery = '';

  DateTime? filterStartDate;
  DateTime? filterEndDate;

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

  void applyDateFilter() {
    setState(() {
      if (filterStartDate != null && filterEndDate != null) {
        final dateFormat =
            DateFormat("dd-MM-yy HH:mm"); // Ajusta el formato según tus datos

        filteredReports = filteredReports.where((report) {
          try {
            // Convierte la fecha del reporte al formato DateTime
            DateTime reportDate = dateFormat.parse(report['date']);

            // Verifica si la fecha está dentro del rango seleccionado
            return reportDate.isAfter(filterStartDate!) &&
                reportDate
                    .isBefore(filterEndDate!.add(const Duration(days: 1)));
          } catch (e) {
            // Si la fecha no se puede convertir, ignora este reporte
            return false;
          }
        }).toList();
      } else {
        // Si no hay rango seleccionado, muestra todos los reportes
        filteredReports = List.from(filteredReports);
      }
    });
  }

  Future<void> onDateRangeSelected(BuildContext context) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020), // Fecha mínima del calendario
      lastDate: DateTime.now().add(const Duration(days: 365)), // Fecha máxima
      initialDateRange: filterStartDate != null && filterEndDate != null
          ? DateTimeRange(
              start: filterStartDate!,
              end: filterEndDate!,
            )
          : null, // Configuración inicial opcional
    );

    if (dateRange != null) {
      setState(() {
        filterStartDate = dateRange.start;
        filterEndDate = dateRange.end;
        applyDateFilter();
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

  Future<void> exportToCSV(BuildContext context, List<dynamic> reports) async {
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
        final productsNames = (report['products_names'] != null &&
                report['products_names'] is List<dynamic>)
            ? (report['products_names'] as List<dynamic>)
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

      // Mostrar mensaje de éxito con Snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV generado con éxito en: $path'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _deleteReport(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este cliente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _reportService.deleteReport(id);
      ReportServiceCashier.fetchReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final snapshotData = await reports;
            await exportToCSV(context, snapshotData);
          },
          icon: const Icon(Icons.download),
          label: const Text('Exportar CSV'),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            // Dropdown "Filtrar por"
            Expanded(
              child: Padding(
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
            ),
            const SizedBox(width: 8),
            // Botón para el selector de fecha
            ElevatedButton(
              onPressed: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020), // Fecha inicial del rango
                  lastDate: DateTime.now()
                      .add(const Duration(days: 365)), // Fecha máxima
                  initialDateRange: DateTimeRange(
                    start: DateTime.now(),
                    end: DateTime.now().add(const Duration(days: 7)),
                  ),
                );
                if (dateRange != null) {
                  setState(() {
                    // Aquí puedes manejar el rango de fechas seleccionado
                    filterStartDate = dateRange.start;
                    filterEndDate = dateRange.end;
                    applyDateFilter();
                  });
                }
              },
              child: const Text('Filtrar por fecha'),
            ),
          ],
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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: filteredReports.map((report) {
                          final id = report['id']?['id']?['String'] ?? 'N/A';
                          final productsNames =
                              (report['products_names'] != null &&
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
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteReport(
                                        report['id']?['id']?['String']),
                                  ),
                                ],
                              ))
                            ],
                          );
                        }).toList(),
                      ),
                    ),
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
