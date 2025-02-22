import 'package:choi_pos/services/users/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  String fullname = '';
  String tutorName = '';
  DateTime? created;
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
    'Mensualidad Standard Niños 2-4',
    'Mensualidad Sabatina Standard',
    'Mensualidad Sabatina 2-4'
  ];

  final List<Map<String, dynamic>> schedules = [
    {
      "days": ['Martes', 'Jueves'],
      "name": 'MJ',
      "times": ['3:00 PM - 4:30 PM', '4:30 PM - 6:00 PM', '6:00 PM - 7:30 PM']
    },
    {
      "days": ['Sabado'],
      "name": 'SAB',
      "times": [
        '9:00 AM - 10:00 AM',
        '10:00 AM - 12:00 PM',
        '2:00 PM - 3:00 PM',
        '3:00 PM - 5:00 PM'
      ]
    },
    {
      "days": ['Lunes', 'Miércoles', 'Viernes'],
      "name": 'LMV',
      "times": [
        '3:00 PM - 4:00 PM',
        '4:00 PM - 5:00 PM',
        '5:00 PM - 6:00 PM',
        '6:00 PM - 7:00 PM'
      ]
    }
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != created) {
      setState(() {
        created = picked;
      });
    }
  }

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
        "times": selectedTime,
        "is_active": isActive,
        "tutor_name": tutorName,
        "created": created?.toString()
      };

      try {
        await _customerService.registerCustomer(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente registrado con éxito')),
        );
        _formKey.currentState?.reset();
        context.pop();
      } catch (e) {
        String errorMessage = 'Error al registrar cliente';
        if (e is Exception && e.toString().contains('409')) {
          errorMessage = 'El cliente ya está registrado en la base de datos.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
                  decoration:
                      const InputDecoration(labelText: 'Nombre completo'),
                  onSaved: (value) => fullname = value ?? '',
                  validator: (value) => value?.isEmpty == true
                      ? 'El nombre es obligatorio'
                      : null,
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
                      const InputDecoration(labelText: 'Nombre del tutor'),
                  keyboardType: TextInputType.text,
                  onSaved: (value) => tutorName = value ?? '',
                  validator: (value) => value?.isEmpty == true
                      ? 'El nombre del tutor es obligatorio'
                      : null,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value ?? '',
                  validator: (value) => value?.isEmpty == true
                      ? 'El correo es obligatorio'
                      : null,
                ),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha de creación',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  controller: TextEditingController(
                    text: created != null ? dateFormat.format(created!) : '',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedPlan,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona una mensualidad',
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
                          .firstWhere((plan) =>
                              plan["name"] == selectedSchedule)["times"]
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
                    validator: (value) => value == null
                        ? 'Por favor selecciona un horario'
                        : null,
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
                SwitchListTile(
                  title: const Text('¿Es cliente activo?'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
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
      ),
    );
  }
}
