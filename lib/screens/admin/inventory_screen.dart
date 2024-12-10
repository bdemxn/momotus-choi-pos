import 'package:choi_pos/widgets/inventory_table.dart';
import 'package:choi_pos/widgets/sidebar_admin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/admin/inventory/create-item'),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.lightBlue,),
                            Text('Añadir al inventario', style: TextStyle(color: Colors.lightBlue),)
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/admin/inventory/create-category'),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.lightBlue,),
                            Text('Crear categoría', style: TextStyle(color: Colors.lightBlue),)
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // DataTable:
                const InventoryTable()
              ],
            )
          )
        ],
      ),
    );
  }
}