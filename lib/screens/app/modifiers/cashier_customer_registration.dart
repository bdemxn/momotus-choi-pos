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
  bool isActive = false;
  String? selectedPlan;

  String? selectedSchedule;
  String? selectedTime;
  List<String> availableTimes = [];

  final List<String> plans = [
    'Mensualidad Standard',
    'Mensualidad Niños 2-4',
    'Mensualidad Sabatina Standard',
    'Mensualidad Sabatina 2-4'
  ];

  final List<Map<String, dynamic>> schedules = [
    {
      "days": ['Martes', 'Jueves'],
      "id": "schedules:9yjffzdtsvlh7my13d8m",
      "name": 'Standard 2',
      "times": ['3:00 PM - 4:30 PM', '4:30 PM - 6:00 PM', '6:00 PM - 7:30 PM']
    },
    {
      "days": ['Sabado'],
      "id": "schedules:e9dfske3l73xifstsbsa",
      "name": 'Sabatino',
      "times": [
        '9:00 AM - 10:00 AM',
        '10:00 AM - 12:00 PM',
        '2:00 PM - 3:00 PM',
        '3:00 PM - 5:00 PM'
      ]
    },
    {
      "days": ['Lunes', 'Miércoles', 'Viernes'],
      "id": "schedules:f1iavfymp4w7s4egjp7w",
      "name": 'Standard 1',
      "times": [
        '3:00 PM - 4:00 PM',
        '4:00 PM - 5:00 PM',
        '5:00 PM - 6:00 PM',
        '6:00 PM - 7:00 PM'
      ]
    }
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
        "monthly_pay_ref": selectedPlan,
        "schedule": selectedSchedule,
        "is_active": isActive,
        "times": selectedTime
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
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                
                const SizedBox(height: 20),
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
                DropdownButtonFormField<String>(
                  value: selectedSchedule,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona un plan',
                  ),
                  items: schedules.map((plan) {
                    return DropdownMenuItem<String>(
                      value: plan["name"],
                      child: Text(plan["name"]),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSchedule = newValue;
                      // Actualizar los horarios disponibles según el plan seleccionado
                      availableTimes = schedules
                          .firstWhere(
                              (plan) => plan["name"] == selectedSchedule)["times"]
                          .cast<String>();
                      selectedTime = null; // Reiniciar el horario seleccionado
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor selecciona un plan' : null,
                ),
                const SizedBox(height: 20),
                if (selectedSchedule !=
                    null) // Mostrar el segundo dropdown si hay un plan seleccionado
                  DropdownButtonFormField<String>(
                    value: selectedTime,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un horario',
                    ),
                    items: availableTimes.map((time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedTime = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Por favor selecciona un horario' : null,
                  ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('¿Es menor de edad?'),
                  value: isMinor,
                  onChanged: (value) => setState(() => isMinor = value),
                ),
                SwitchListTile(
                  title: const Text('¿Es cliente activo?'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Registrar Cliente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
