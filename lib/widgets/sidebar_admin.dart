import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarAdmin extends StatelessWidget {
  const SidebarAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Logo:
          Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const Image(
                    image: AssetImage('assets/choi-image.png'),
                    height: 20,
                  ),
                  // Go back login form:
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Row(
                      children: [
                        Icon(Icons.reset_tv_rounded),
                        SizedBox(width: 8),
                        Text('Cerrar sesión')
                      ],
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 30),

          // Overview:
          TextButton(
            onPressed: () => context.go('/admin'),
            child: const Row(
              children: [
                Icon(
                  Icons.home,
                ),
                SizedBox(width: 8),
                Text('Resumen')
              ],
            ),
          ),

          // Inventory:
          TextButton(
            onPressed: () => context.go('/admin'),
            child: const Row(
              children: [
                Icon(Icons.inventory, size: 20),
                SizedBox(width: 8),
                Text('Inventario')
              ],
            ),
          ),

          // Users
          TextButton(
            onPressed: () => context.go('/admin'),
            child: const Row(
              children: [
                Icon(Icons.verified_user_sharp, size: 20),
                SizedBox(width: 8),
                Text('Usuarios')
              ],
            ),
          ),

          // Reports
          TextButton(
            onPressed: () => context.go('/reports'),
            child: const Row(
              children: [
                Icon(Icons.report, size: 20),
                SizedBox(width: 8),
                Text('Reportes')
              ],
            ),
          ),

          // Customers
          TextButton(
            onPressed: () => context.go('/admin'),
            child: const Row(
              children: [
                Icon(Icons.account_circle, size: 20),
                SizedBox(width: 8),
                Text('Clientes')
              ],
            ),
          )
        ],
      ),
    );
  }
}
