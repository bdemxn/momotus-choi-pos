import 'package:choi_pos/widgets/sidebar_admin.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SidebarAdmin()
            ],
          ),
          Center(
            child: Text('data'),
          )

        ],
      ),
    );
  }
}
