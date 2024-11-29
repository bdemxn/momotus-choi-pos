import 'package:choi_pos/widgets/inventory_table.dart';
import 'package:choi_pos/widgets/sidebar_admin.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SidebarAdmin()
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Encuentra todo tu stock aquí',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // DataTable:
                InventoryTable()
          
              ],
            )
          )
        ],
      ),
    );
  }
}