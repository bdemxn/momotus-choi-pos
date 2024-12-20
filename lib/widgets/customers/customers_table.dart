import 'package:choi_pos/services/users/customer_service.dart';
import 'package:flutter/material.dart';

class CustomerTable extends StatefulWidget {
  const CustomerTable({super.key});

  @override
  State<CustomerTable> createState() => _CustomerTableState();
}

class _CustomerTableState extends State<CustomerTable> {
  final _customerService = CustomerService();
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

  Future<void> _deleteCustomer(String id) async {
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
      await _customerService.deleteCustomer(id);
      _fetchCustomers();
    }
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
        return Flexible(
          child: SingleChildScrollView(
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
                  DataColumn(label: Text('Preferido')),
                  DataColumn(label: Text('Acciones')), // Nueva columna
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
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCustomer(customer['id']),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
