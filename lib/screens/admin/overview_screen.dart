import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [SidebarAdmin()],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Bienvenido a tu POS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Coming soon:
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Próximamente más funcionalidades al POS'),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Image(image: AssetImage('assets/choi-user.png'), height: 100,),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}
