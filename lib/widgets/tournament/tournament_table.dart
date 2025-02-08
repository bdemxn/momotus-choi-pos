import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:flutter/material.dart';

class TournamentTable extends StatefulWidget {
  final List<dynamic> tournaments;
  final VoidCallback onTournamentUpdated;

  const TournamentTable({
    super.key,
    required this.tournaments,
    required this.onTournamentUpdated,
  });

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
      widget.onTournamentUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Acciones')),
      ],
      rows: widget.tournaments.map((tournament) {
        return DataRow(cells: [
          DataCell(Text(tournament["name"])),
          DataCell(Text(tournament["price"].toString())),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirmar Eliminación'),
                          content: Text(
                              '¿Estás seguro de que quieres eliminar "${tournament['name']}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm ?? false) {
                      await _tournamentServices
                          .deleteTournament(tournament['id']);
                      widget.onTournamentUpdated();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.update, color: Colors.blueAccent),
                  onPressed: () => _editTournament(context, tournament),
                ),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
