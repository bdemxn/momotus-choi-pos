import 'package:flutter/material.dart';

class UsersTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const UsersTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Nombre Completo')),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Nombre de Usuario')),
            DataColumn(label: Text('Sucursal')),
          ],
          rows: data
              .map(
                (item) => DataRow(cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['fullname'])),
                  DataCell(Text(item['role'])),
                  DataCell(Text(item['username'])),
                  DataCell(Text(item['branch'].toString())),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}