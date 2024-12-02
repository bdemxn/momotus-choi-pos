import 'package:choi_pos/services/customer_service.dart';
import 'package:flutter/material.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();

  String fullname = '';
  String phone = '';
  String email = '';
  bool isMinor = false;
  bool isPreferred = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final customerData = {
        "fullname": fullname,
        "is_minor": isMinor,
        "phone": phone,
        "email": email,
        "is_preferred": isPreferred,
      };

      try {
        await _customerService.registerCustomer(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente registrado con éxito')),
        );
        _formKey.currentState?.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar cliente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Clientes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Center(
                child: Image(
                  image: AssetImage('assets/choi-client.png'),
                  height: 100,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                onSaved: (value) => fullname = value ?? '',
                validator: (value) =>
                    value?.isEmpty == true ? 'El nombre es obligatorio' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => phone = value ?? '',
                validator: (value) => value?.isEmpty == true
                    ? 'El teléfono es obligatorio'
                    : null,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value ?? '',
                validator: (value) =>
                    value?.isEmpty == true ? 'El correo es obligatorio' : null,
              ),
              SwitchListTile(
                title: const Text('¿Es menor de edad?'),
                value: isMinor,
                onChanged: (value) => setState(() => isMinor = value),
              ),
              SwitchListTile(
                title: const Text('¿Es cliente preferido?'),
                value: isPreferred,
                onChanged: (value) => setState(() => isPreferred = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Registrar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
