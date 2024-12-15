import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 30),
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
                      'Torneos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Todos los torneos que hallas creado apareceran aquí',
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
                              onPressed: () =>
                                  context.go('/admin/tournaments/create-tournament'),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.lightBlue,
                                  ),
                                  Text(
                                    'Añadir torneo',
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
                  ],
                )),
          )
        ],
      ),
    );
  }
}
