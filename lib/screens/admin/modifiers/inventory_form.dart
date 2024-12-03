import 'package:choi_pos/services/create_inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Para el admin: alan.arguello | Prueba1#
// para el cajero: cajero1 | Testing123@

class InventoryFormWidget extends StatefulWidget {
  const InventoryFormWidget({super.key});

  @override
  State<InventoryFormWidget> createState() => _InventoryFormWidgetState();
}

class _InventoryFormWidgetState extends State<InventoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> inventoryData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category': _categoryController.text,
        'bar_code': _barcodeController.text,
        'quantity': int.parse(_quantityController.text),
      };

      try {
        setState(() => _isLoading = true);
        await createUser(inventoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto creado exitosamente')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Crea un item para el inventario'),
          leading: IconButton(
              onPressed: () => context.go('/admin/inventory'),
              icon: const Icon(Icons.arrow_back))),
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
                controller: _barcodeController,
                decoration:
                    const InputDecoration(labelText: 'Código de barras'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El código de barras no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration:
                    const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La categoría no puede estar vacía';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cantidad no puede estar vacía';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
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
