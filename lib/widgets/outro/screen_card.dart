import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScreenCard extends StatelessWidget {
  const ScreenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20),
      child: TextButton(
        onPressed: () => context.go('/admin/reports'),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        )
      )
    );
  }
}