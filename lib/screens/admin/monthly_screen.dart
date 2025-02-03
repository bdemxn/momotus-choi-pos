import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:choi_pos/widgets/monthly/monthly_table.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MonthlyScreen extends StatelessWidget {
  const MonthlyScreen({super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mensualidades',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Crea mensualidades',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                context.go("/admin/monthly/create-monthly"),
                            child: const Row(
                              children: [
                                Text("Crea una mensualidad"),
                                Icon(Icons.add)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: MonthlyTable(),
                      ),
                    )
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
