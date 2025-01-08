import 'package:choi_pos/screens/app/modifiers/payment_dialog.dart';
import 'package:choi_pos/services/payments/payment_services.dart';
import 'package:flutter/material.dart';

class PaymentTable extends StatefulWidget {
  const PaymentTable({super.key});

  @override
  _PaymentTableState createState() => _PaymentTableState();
}

class _PaymentTableState extends State<PaymentTable> {
  final PaymentServices _paymentServices = PaymentServices();

  @override
  void initState() {
    super.initState();
    _paymentServices.getPayments();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _paymentServices.getPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final paymentsList = _paymentServices.paymentList;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Cliente')),
                DataColumn(label: Text('Año')),
                DataColumn(label: Text('Horario')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: paymentsList.map((payment) {
                return DataRow(cells: [
                  DataCell(Text(payment['client_name'])),
                  DataCell(Text(payment['year'].toString())),
                  DataCell(Text(payment['schedule'])),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _paymentServices.getPayments();
                        });
                        
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PaymentDialog(
                              id: payment['id'],
                              clientName: payment['client_name'],
                              months: payment['months'][0], // Mapeo de meses
                            );
                          },
                        );
                      },
                      child: const Text('Agregar Pago'),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
