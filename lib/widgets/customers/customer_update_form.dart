import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:choi_pos/services/users/customer_service.dart';

class CustomerUpdateForm extends StatefulWidget {
  final Map<String, dynamic> customerData;

  const CustomerUpdateForm({super.key, required this.customerData});

  @override
  State<CustomerUpdateForm> createState() => _CustomerUpdateFormState();
}

class _CustomerUpdateFormState extends State<CustomerUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();

  late String fullname;
  late String phone;
  late String email;
  late bool isMinor;
  late bool isPreferred;
  late String? selectedPlan;

  final List<String> plans = [
    'Mensualidad Standard',
    'Mensualidad Niños 2-4',
    'Mensualidad Sabatina Standard',
    'Mensualidad Sabatina 2-4'
  ];

  @override
  void initState() {
    super.initState();
    fullname = widget.customerData['fullname'] ?? '';
    phone = widget.customerData['phone'] ?? '';
    email = widget.customerData['email'] ?? '';
    isMinor = widget.customerData['is_minor'] ?? false;
    isPreferred = widget.customerData['is_preferred'] ?? false;
    selectedPlan = widget.customerData['monthly_pay_ref'];
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedData = {
        "id": widget.customerData['id'],
        "fullname": fullname,
        "is_minor": isMinor,
        "phone": phone,
        "email": email,
        "is_preferred": isPreferred,
        "monthly_pay_ref": selectedPlan,
      };

      try {
        await _customerService.updatedCustomer(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente actualizado con éxito')),
        );
        context.go('/admin/customers');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar cliente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: fullname,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                onSaved: (value) => fullname = value ?? '',
                validator: (value) =>
                    value?.isEmpty == true ? 'El nombre es obligatorio' : null,
              ),
              TextFormField(
                initialValue: phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => phone = value ?? '',
                validator: (value) => value?.isEmpty == true
                    ? 'El teléfono es obligatorio'
                    : null,
              ),
              TextFormField(
                initialValue: email,
                decoration:
                    const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value ?? '',
                validator: (value) =>
                    value?.isEmpty == true ? 'El correo es obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedPlan,
                decoration:
                    const InputDecoration(labelText: 'Selecciona un plan'),
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
                child: const Text('Actualizar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
