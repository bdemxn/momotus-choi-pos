// import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TournamentForm extends StatefulWidget {
  const TournamentForm({super.key});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TournamentServices _tournamentServices = TournamentServices();

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Crea torneos'),
          leading: IconButton(
              onPressed: () => context.go('/admin/tournaments'),
              icon: const Icon(Icons.arrow_back))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Image(
                  image: AssetImage('assets/choi-client.png'),
                  height: 100,
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del exámen'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del exámen no puede estar vacío';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration:
                    const InputDecoration(labelText: 'Valor del exámen'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El valor del exámen no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _tournamentServices.createTournament(
                          _nameController.text, _priceController.text),
                      child: const Text(
                        'Crear torneo',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
