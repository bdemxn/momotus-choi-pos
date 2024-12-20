import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [SidebarAdmin()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Bienvenido a tu POS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Coming soon:
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Próximamente más funcionalidades al POS'),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Image(image: AssetImage('assets/choi-user.png'), height: 100,),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ElevatedButton(
                    onPressed: () => context.go('/admin/support'),
                    child: const Row(
                      children: [
                        Icon(Icons.support_agent_outlined, color: Colors.lightBlue,),
                        SizedBox(width: 5,),
                        Text('Soporte técnico', style: TextStyle(color: Colors.lightBlue),)
                      ],
                    )
                  ),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}
