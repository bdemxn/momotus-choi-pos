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
  final TextEditingController _searchController = TextEditingController();
  // String _selectedSchedule = 'Todos'; 

  List<dynamic> filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    await _paymentServices.getPayments();
    setState(() {
      filteredPayments = _paymentServices.paymentList;
    });
  }

  void _filterPayments() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      filteredPayments = _paymentServices.paymentList.where((payment) {
        final clientNameMatches = payment['client_name']
            .toLowerCase()
            .contains(searchQuery);
        // final scheduleMatches = _selectedSchedule == 'Todos' ||
        //     payment['schedule'] == _selectedSchedule;
        return clientNameMatches; // && scheduleMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por cliente',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _filterPayments(),
                ),
              ),
              const SizedBox(width: 16),
              // DropdownButton<String>(
              //   value: _selectedSchedule,
              //   onChanged: (value) {
              //     if (value != null) {
              //       setState(() {
              //         _selectedSchedule = value;
              //         _filterPayments();
              //       });
              //     }
              //   },
              //   items: const [
              //     'Todos',
              //     'Standard 1',
              //     'Standard 2',
              //     'Sabatino'
              //   ].map((schedule) {
              //     return DropdownMenuItem<String>(
              //       value: schedule,
              //       child: Text(schedule),
              //     );
              //   }).toList(),
              // ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
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
                rows: filteredPayments.map((payment) {
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
                                months: payment['months'][0],
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
          ),
        ),
      ],
    );
  }
}