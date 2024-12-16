import 'package:flutter/material.dart';

class TechnicalSupportForm extends StatefulWidget {
  const TechnicalSupportForm({super.key});

  @override
  State<TechnicalSupportForm> createState() => _TechnicalSupportFormState();
}

class _TechnicalSupportFormState extends State<TechnicalSupportForm> {
  final _formKey = GlobalKey<FormState>(); // For form validation
  String? _title;
  String? _description;
  String? _branch;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: Send the form data to the backend or process it as needed
      print('Título: $_title');
      print('Descripción: $_description');
      print('Sucursal: $_branch');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario enviado correctamente')),
      );

      // Optionally, reset the form fields
      _formKey.currentState!.reset();
      setState(() {
        _branch = null; // Reset dropdown selection
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Soporte Técnico'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un título';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Sucursal',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una sucursal';
                  }
                  return null;
                },
                onSaved: (value) {
                  _branch = value;
                },
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
