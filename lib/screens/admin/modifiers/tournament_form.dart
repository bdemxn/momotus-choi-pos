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
  final TextEditingController _locationController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _branchController = TextEditingController();

  final bool _isLoading = false;

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
                    const InputDecoration(labelText: 'Nombre del torneo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del torneo no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                    labelText: 'Lugar del torneo'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El lugar del torneo no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => {},
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
