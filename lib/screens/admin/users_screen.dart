import 'package:choi_pos/widgets/sidebar_admin.dart';
import 'package:choi_pos/widgets/users_table.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> mockData = [
      {
        'id': 1,
        'fullname': 'Kevin Bonilla',
        'role': 'admin',
        'username': 'bdemxn',
        'branch': 'Villa Sol'
      }
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
                UsersTable(data: mockData,)
          
              ],
            )
          )
        ],
      ),
    );
  }
}