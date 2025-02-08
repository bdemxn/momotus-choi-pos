import 'package:choi_pos/services/monthly/monthly_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MonthlyFormWidget extends StatefulWidget {
  const MonthlyFormWidget({super.key});

  @override
  State<MonthlyFormWidget> createState() => _MonthlyFormWidgetState();
}

class _MonthlyFormWidgetState extends State<MonthlyFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  final MonthlyServices _monthlyServices = MonthlyServices();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> monthlyData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        "discount_preferred": double.parse(_discountController.text)
      };

      try {
        await _monthlyServices.createMonthly(monthlyData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto creado exitosamente')),
        );
        _formKey.currentState!.reset();
        context.go('/admin/monthly');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea una mensualidad'),
        leading: IconButton(
          onPressed: () => context.go('/admin/monthly'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio no puede estar vacío';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Descuento preferencial'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El descuento no puede estar vacío';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text(
                  'Crear Objeto',
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
