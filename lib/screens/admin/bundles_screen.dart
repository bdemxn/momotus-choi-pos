import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:choi_pos/widgets/bundles/bundles_table.dart';

class BundlesScreen extends StatelessWidget {
  const BundlesScreen({super.key});

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
                      'Combos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Puedes armar combos a partir de tu inventario existente',
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
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: ElevatedButton(
                              onPressed: () => {
                                context.go('/admin/bundles/create-bundle'),
                                context.go('/admin/bundles/create-combos'),
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.lightBlue,
                                  ),
                                  Text(
                                    'Añadir Combos',
                                    style: TextStyle(color: Colors.lightBlue),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // DataTable:
                    const BundlesTable()
                  ],
                )),
          )
        ],
      ),
    );
  }
}
