import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:choi_pos/widgets/tournament/tournament_table.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final TournamentServices _tournamentServices = TournamentServices();

  @override
  void initState() {
    super.initState();
    _tournamentServices.getTournaments();
  }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Examenes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Todos los examenes que hayas creado apareceran aquí',
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
                              onPressed: () => context
                                  .go('/admin/tournaments/create-tournament'),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.lightBlue,
                                  ),
                                  Text(
                                    'Añadir examen',
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
                    const Expanded(
                      child: TournamentTable(),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
