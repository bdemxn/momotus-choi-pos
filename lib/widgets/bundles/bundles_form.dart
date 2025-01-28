import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BundlesForm extends StatefulWidget {
  const BundlesForm({super.key});

  @override
  State<BundlesForm> createState() => _BundlesFormState();
}

class _BundlesFormState extends State<BundlesForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bundleController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> bundleData = {
        'fullname': _bundleController.text,
        'username': _discountController.text,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Crea usuarios'),
          leading: IconButton(
              onPressed: () => context.go('/admin/users'),
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
                  image: AssetImage('assets/choi-user.png'),
                  height: 100,
                ),
              ),
              TextFormField(
                controller: _bundleController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del combo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                    labelText: 'Descuento'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El descuento no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text(
                  'Crear combo',
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
