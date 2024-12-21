import 'package:choi_pos/services/reports/get_reports_cashier.dart';
import 'package:flutter/material.dart';

class ReportCardCashier extends StatefulWidget {
  const ReportCardCashier({super.key});

  @override
  State<ReportCardCashier> createState() => _ReportCardCashierState();
}

class _ReportCardCashierState extends State<ReportCardCashier> {
  late Future<List<dynamic>> reports;

  @override
  void initState() {
    super.initState();
    reports = ReportServiceCashier.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: reports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay reportes disponibles'));
        }

        final reportList = snapshot.data!;

        return SingleChildScrollView(
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
              ],
              rows: reportList.map((report) {
                final id = report['id']?['id']?['String'] ?? 'N/A';
                final productsNames = (report['products_names'] as List<dynamic>)
                    .map((product) => product.toString())
                    .join(', ');
          
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
        );
      },
    );
  }
}
