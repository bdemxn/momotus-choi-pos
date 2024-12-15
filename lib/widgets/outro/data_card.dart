import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DataCard extends StatelessWidget {
  const DataCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(10),
        ), child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ventas totales:', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                  ),
                ),
                Text('560')
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text('\$300.00', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),)
                )
              ],
            ),
            TextButton(onPressed: () => context.go('/admin'), child: const Icon(Icons.abc, color: Colors.blueAccent,))
          ],
        ),
      ),
    );
  }
}