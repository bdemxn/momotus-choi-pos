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
                                  onPressed: () async => {
                                        await _showChangePasswordDialog(
                                            context, tournament['name'], tournament['id'])
                                      }),
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

  Future<void> _showChangePasswordDialog(
      BuildContext context, String fullname, String userId) async {
    final _formKey = GlobalKey<FormState>(); // Llave local del formulario

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar cambio de contraseña'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('¿Estás seguro de cambiar la contraseña de "$fullname"?'),
                TextFormField(
                  controller: _newTournamentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pon una contraseña';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Repite la contraseña',
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite nuevamente la contraseña';
                    }
                    if (value != _newTournamentNameController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Cambiar contraseña'),
            ),
          ],
        );
      },
    );

    _newTournamentNameController.clear();
    _newPriceController.clear();

    if (confirm ?? false) {
      //  await _tournamentServices.updateUserPassword(
      //   _newTournamentNameController.text,
      //   userId,
      // );
      setState(() {});
    }
  }
}
