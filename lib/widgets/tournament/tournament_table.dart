import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:flutter/material.dart';

class TournamentTable extends StatefulWidget {
  const TournamentTable({super.key});

  @override
  State<TournamentTable> createState() => _TournamentTableState();
}

class _TournamentTableState extends State<TournamentTable> {
  final TournamentServices _tournamentServices = TournamentServices();
  final TextEditingController _newTournamentNameController =
      TextEditingController();
  final TextEditingController _newPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tournamentServices.getTournaments();
  }

  Future<void> _editTournament(
      BuildContext context, Map<String, dynamic> tournament) async {
    _newTournamentNameController.text = tournament['name'];
    _newPriceController.text = tournament['price'].toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Torneo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newTournamentNameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Torneo'),
              ),
              TextField(
                controller: _newPriceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirm ?? false) {
      final updatedName = _newTournamentNameController.text;
      final updatedPrice = double.tryParse(_newPriceController.text) ?? 0.0;

      await _tournamentServices.updateTournament(
        tournament['id'],
        updatedName,
        updatedPrice,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _tournamentServices.getTournaments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final tournamentList = _tournamentServices.tournamentList;

        return Flexible(
          fit: FlexFit.tight,
          flex: 5,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Imagen')),
                  DataColumn(label: Text('Nombre Exámen')),
                  DataColumn(label: Text('Precio')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: tournamentList
                    .map(
                      (tournament) => DataRow(cells: [
                        const DataCell(Image(
                          image: AssetImage('assets/choi-user.png'),
                          height: 40,
                        )),
                        DataCell(Text(tournament['name'])),
                        DataCell(Text(tournament['price'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Confirmar Eliminación'),
                                        content: Text(
                                            '¿Estás seguro de que quieres eliminar "${tournament['name']}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm ?? false) {
                                    await _tournamentServices
                                        .deleteTournament(tournament['id']);
                                    setState(() {});
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.update,
                                    color: Colors.blueAccent),
                                onPressed: () =>
                                    _editTournament(context, tournament),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
