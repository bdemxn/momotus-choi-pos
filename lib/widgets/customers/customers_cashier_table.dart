import 'package:choi_pos/services/users/create_cashier_customer.dart';
import 'package:flutter/material.dart';

class CustomerCashierTable extends StatefulWidget {
  const CustomerCashierTable({super.key});

  @override
  State<CustomerCashierTable> createState() => _CustomerCashierTableState();
}

class _CustomerCashierTableState extends State<CustomerCashierTable> {
  final _customerService = CashierCustomerService();
  late Future<List<Map<String, dynamic>>> _customers;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() {
    setState(() {
      _customers = _customerService.fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _customers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar clientes: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay clientes registrados.'),
          );
        }

        final customers = snapshot.data!;

        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Imagen')),
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Teléfono')),
                  DataColumn(label: Text('Correo')),
                  DataColumn(label: Text('¿Menor de Edad?')),
                  DataColumn(label: Text('Preferido')), // Nueva columna
                ],
                rows: customers.map((customer) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Image.asset('assets/choi-client.png', height: 40),
                      ),
                      DataCell(Text(customer['fullname'] ?? 'N/A')),
                      DataCell(Text(customer['phone'] ?? 'N/A')),
                      DataCell(Text(customer['email'] ?? 'N/A')),
                      DataCell(Text(customer['is_minor'] ? 'Sí' : 'No')),
                      DataCell(Text(customer['is_preferred'] ? 'Sí' : 'No')),
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
