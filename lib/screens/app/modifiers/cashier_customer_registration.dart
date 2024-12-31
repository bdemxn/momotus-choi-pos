import 'package:choi_pos/services/users/create_cashier_customer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CashierCustomerRegistration extends StatefulWidget {
  const CashierCustomerRegistration({super.key});

  @override
  State<CashierCustomerRegistration> createState() =>
      _CashierCustomerRegistrationState();
}

class _CashierCustomerRegistrationState
    extends State<CashierCustomerRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CashierCustomerService();

  String fullname = '';
  String phone = '';
  String email = '';
  bool isMinor = false;
  bool isPreferred = false;

  // Variable para almacenar la opción seleccionada
  String? selectedPlan;

  // Lista de opciones para el Dropdown
  final List<String> plans = [
    'Mensualidad Standard',
    'Mensualidad Niños 2-4',
    'Mensualidad Sabatina Standard',
    'Mensualidad Sabatina 2-4'
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final customerData = {
        "fullname": fullname,
        "is_minor": isMinor,
        "phone": phone,
        "email": email,
        "is_preferred": isPreferred,
        "monthly_pay_ref": selectedPlan,  // Agregamos el plan seleccionado
      };

      try {
        await _customerService.registerCustomer(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente registrado con éxito')),
        );
        _formKey.currentState?.reset();
        context.go('/app');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar cliente')),
        );
        print(e);
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
              const SizedBox(height: 20),
              
              // DropdownButtonFormField para seleccionar un plan
              DropdownButtonFormField<String>(
                value: selectedPlan,
                decoration: const InputDecoration(
                  labelText: 'Selecciona un plan',
                ),
                items: plans.map((plan) {
                  return DropdownMenuItem<String>(
                    value: plan,
                    child: Text(plan),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedPlan = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Por favor selecciona un plan' : null,
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
