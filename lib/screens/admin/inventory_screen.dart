import 'package:choi_pos/widgets/inventory_table.dart';
import 'package:choi_pos/widgets/sidebar_admin.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> mockData = [
      {
        'id': 1,
        'barcode': '123456789012',
        'category': 'Electrónica',
        'name': 'Audífonos',
        'price': 25.99,
        'quantity': 10,
      },
      {
        'id': 2,
        'barcode': '987654321098',
        'category': 'Hogar',
        'name': 'Lámpara',
        'price': 45.00,
        'quantity': 5,
      },
    ];

    return Scaffold(
      body: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SidebarAdmin()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Encuentra todo tu stock aquí',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // DataTable:
                
                InventoryTable(data: mockData,)
          
              ],
            )
          )
        ],
      ),
    );
  }
}