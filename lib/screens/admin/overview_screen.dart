import 'package:choi_pos/widgets/sidebar_admin.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  // Color constants:
  final Color _containerColor = const Color.fromARGB(255, 34, 34, 34);

  // Text constants:
  final TextStyle _header1 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

    final TextStyle _header2 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: _containerColor,
              width: 1020,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('General', style: _header1),
                      Text('Bienvenido a Choi POS v1.2', style: _header2,)
                    ],
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
