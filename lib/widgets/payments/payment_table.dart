import 'package:choi_pos/screens/app/modifiers/payment_dialog.dart';
import 'package:choi_pos/services/payments/payment_services.dart';
import 'package:choi_pos/widgets/payments/payment_dialog.dart';
import 'package:flutter/material.dart';

class PaymentTable extends StatefulWidget {
  const PaymentTable({super.key});

  @override
  _PaymentTableState createState() => _PaymentTableState();
}

class _PaymentTableState extends State<PaymentTable> {
  final PaymentServices _paymentServices = PaymentServices();
  final TextEditingController _searchController = TextEditingController();

  String _selectedSchedule = 'Todos';
  String? _selectedTime;

  List<dynamic> filteredPayments = [];

  final List<Map<String, dynamic>> schedules = [
    {
      "days": ['Martes', 'Jueves'],
      "id": "schedules:9yjffzdtsvlh7my13d8m",
      "name": 'MJ',
      "times": ['3:00 PM - 4:30 PM', '4:30 PM - 6:00 PM', '6:00 PM - 7:30 PM']
    },
    {
      "days": ['Sabado'],
      "id": "schedules:e9dfske3l73xifstsbsa",
      "name": 'SAB',
      "times": [
        '9:00 AM - 10:00 AM',
        '10:00 AM - 12:00 PM',
        '2:00 PM - 3:00 PM',
        '3:00 PM - 5:00 PM'
      ]
    },
    {
      "days": ['Lunes', 'Miércoles', 'Viernes'],
      "id": "schedules:f1iavfymp4w7s4egjp7w",
      "name": 'LMV',
      "times": [
        '3:00 PM - 4:00 PM',
        '4:00 PM - 5:00 PM',
        '5:00 PM - 6:00 PM',
        '6:00 PM - 7:00 PM'
      ]
    }
  ];

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
        final clientNameMatches =
            payment['client_name'].toLowerCase().contains(searchQuery);
        final scheduleMatches = _selectedSchedule == 'Todos' ||
            payment['schedule'] == _selectedSchedule;
        final timeMatches = _selectedTime == null ||
            (payment['times'] != null &&
                payment['times'].contains(_selectedTime));

        return clientNameMatches && scheduleMatches && timeMatches;
      }).toList();
    });
  }

  List<String> _getTimesForSelectedSchedule() {
    final schedule = schedules.firstWhere(
      (s) => s['name'] == _selectedSchedule,
      orElse: () => {},
    );
    return schedule.isNotEmpty ? List<String>.from(schedule['times']) : [];
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableTimes = _getTimesForSelectedSchedule();

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

              // Dropdown para Schedules
              DropdownButton<String>(
                value: _selectedSchedule,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSchedule = value;
                      _selectedTime = null; // Reiniciar selección de horario
                      _filterPayments();
                    });
                  }
                },
                items: ['Todos', 'LMV', 'MJ', 'SAB'].map((schedule) {
                  return DropdownMenuItem<String>(
                    value: schedule,
                    child: Text(schedule),
                  );
                }).toList(),
              ),

              const SizedBox(width: 16),

              if (_selectedSchedule != 'Todos')
                DropdownButton<String>(
                  value: _selectedTime,
                  hint: const Text("Selecciona un horario"),
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value;
                      _filterPayments(); // Aplica el filtro al cambiar de horario
                    });
                  },
                  items: availableTimes.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                ),
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
                  DataColumn(label: Text('Días')),
                  DataColumn(label: Text('Horario')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: filteredPayments.map((payment) {
                  return DataRow(cells: [
                    DataCell(Text(payment['client_name'] ?? "Sin nombre")),
                    DataCell(Text(payment['year'].toString())),
                    DataCell(Text(payment['schedule'].toString())),
                    DataCell(Text(payment['times'].toString())),
                    DataCell(
                      Row(
                        children: [
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
                                    months: (payment['months'] is List)
                                        ? payment['months']
                                        : [],
                                  );
                                },
                              );
                            },
                            child: const Text('Ver Pagos'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddPaymentDialog(
                                          clientName: payment["client_name"],
                                          monthlyId: payment["monthly_id"],
                                          onAddToCart: () => {});
                                    });
                              },
                              child: const Text("Pagar mensualidad"),
                            ),
                          ),
                        ],
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
