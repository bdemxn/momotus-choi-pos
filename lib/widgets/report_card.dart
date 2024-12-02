import 'package:choi_pos/services/get_reports.dart';
import 'package:flutter/material.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  late Future<List<dynamic>> reports;

  @override
  void initState() {
    super.initState();
    reports = ReportService.fetchReports(); // Uso del servicio
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

        return ListView.builder(
          itemCount: reportList.length,
          itemBuilder: (context, index) {
            final report = reportList[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(dynamic report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Cajero:', report['cashier']),
            _buildRow('Cliente:', report['customer']),
            _buildRow('Fecha:', report['date']),
            _buildRow('ID Venta:', report['id']),
            _buildRow('Referencia de Pago:', report['payment_ref']),
            _buildRow('Productos:', report['products']),
            _buildRow('Promoción:', report['promocode']),
            _buildRow('Total Pagado:', '\$${report['total_paid']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
