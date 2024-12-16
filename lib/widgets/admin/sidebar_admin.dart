import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarAdmin extends StatelessWidget {
  const SidebarAdmin({super.key});

  // Colors constants:

  final TextStyle _myStyle = const TextStyle(
      color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold);

  final Color _iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo:
          const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Image(
                    image: AssetImage('assets/choi-image.png'),
                    height: 30,
                  ),
                ],
              )),

          const SizedBox(height: 30),

          // Overview:
          TextButton(
            onPressed: () => context.go('/admin'),
            child: Row(
              children: [
                Icon(
                  Icons.home,
                  color: _iconColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen',
                  style: _myStyle,
                )
              ],
            ),
          ),

          // Inventory:
          TextButton(
            onPressed: () => context.go('/admin/inventory'),
            child: Row(
              children: [
                Icon(Icons.inventory, size: 20, color: _iconColor),
                const SizedBox(width: 8),
                Text(
                  'Inventario',
                  style: _myStyle,
                )
              ],
            ),
          ),

          // Users
          TextButton(
            onPressed: () => context.go('/admin/users'),
            child: Row(
              children: [
                Icon(Icons.verified_user_sharp, size: 20, color: _iconColor),
                const SizedBox(width: 8),
                Text('Usuarios', style: _myStyle)
              ],
            ),
          ),

          // Reports
          TextButton(
            onPressed: () => context.go('/admin/reports'),
            child: Row(
              children: [
                Icon(Icons.report, size: 20, color: _iconColor),
                const SizedBox(width: 8),
                Text('Reportes', style: _myStyle)
              ],
            ),
          ),

          // Customers
          TextButton(
            onPressed: () => context.go('/admin/customers'),
            child: Row(
              children: [
                Icon(Icons.account_circle, size: 20, color: _iconColor),
                const SizedBox(width: 8),
                Text('Clientes', style: _myStyle)
              ],
            ),
          ),

          // TextButton(
          //   onPressed: () => context.go('/admin/tournaments'),
          //   child: Row(
          //     children: [
          //       Icon(Icons.data_object_rounded, size: 20, color: _iconColor),
          //       const SizedBox(width: 8),
          //       Text('Torneos', style: _myStyle)
          //     ],
          //   ),
          // ),

          // Go to LoginForm:
          TextButton(
            onPressed: () => context.go('/'),
            child: Row(
              children: [
                Icon(
                  Icons.reset_tv_rounded,
                  color: _iconColor,
                ),
                const SizedBox(width: 8),
                Text('Cerrar sesión', style: _myStyle)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
