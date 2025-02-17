import 'package:choi_pos/widgets/customers/customers_table.dart';
import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [SidebarAdmin()],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Clientes registrados a tu negocio',
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
                            onPressed: () =>
                                context.go('/admin/customers/create-customer'),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.lightBlue,
                                ),
                                Text(
                                  'Añadir cliente',
                                  style: TextStyle(color: Colors.lightBlue),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    // DataTable:
                    const Expanded(flex: 1, child: CustomerTable())
                  ],
                )),
          )
        ],
      ),
    );
  }
}
