import 'package:flutter/material.dart';

class InventoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const InventoryTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Código de Barras')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Precio')),
            DataColumn(label: Text('Cantidad')),
          ],
          rows: data
              .map(
                (item) => DataRow(cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['barcode'])),
                  DataCell(Text(item['category'])),
                  DataCell(Text(item['name'])),
                  DataCell(Text(item['price'].toString())),
                  DataCell(Text(item['quantity'].toString())),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}