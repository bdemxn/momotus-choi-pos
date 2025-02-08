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
  List<dynamic> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _tournamentServices.getTournaments();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    await _tournamentServices.getTournaments();
    setState(() {
      _tournaments = _tournamentServices.tournamentList;
    });
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
                              onPressed: () async {
                                // Navega a TournamentForm y espera el resultado
                                final result = await context.push<bool>(
                                    '/admin/tournaments/create-tournament');
                                // Si el resultado es `true`, actualiza la lista de torneos
                                if (result == true) {
                                  await _loadTournaments();
                                }
                              },
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
                    Expanded(
                      child: TournamentTable(
                        tournaments: _tournaments,
                        onTournamentUpdated: _loadTournaments,
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
