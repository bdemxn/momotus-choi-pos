import 'package:choi_pos/services/category/get_categories.dart';
import 'package:choi_pos/services/inventory/create_inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InventoryFormWidget extends StatefulWidget {
  final VoidCallback onInventoryUpdated;

  const InventoryFormWidget({super.key, required this.onInventoryUpdated});

  @override
  State<InventoryFormWidget> createState() => _InventoryFormWidgetState();
}

class _InventoryFormWidgetState extends State<InventoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  bool _isFetchingCategories = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isFetchingCategories = true;
    });

    try {
      final categories = await fetchCategories();
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las categorías: $e')),
      );
    } finally {
      setState(() {
        _isFetchingCategories = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> inventoryData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'bar_code': _barcodeController.text,
        'quantity': int.parse(_quantityController.text),
      };

      try {
        setState(() => _isLoading = true);
        await createInventoryItemCashier(inventoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto creado exitosamente')),
        );
        _formKey.currentState!.reset();
        context.go('/admin/inventory');
        widget.onInventoryUpdated();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
        widget.onInventoryUpdated();
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
              // TextFormField(
              //   controller: _categoryController,
              //   decoration:
              //       const InputDecoration(labelText: 'Categoría'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'La categoría no puede estar vacía';
              //     }
              //     return null;
              //   },
              // ),

              _isFetchingCategories
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration:
                          const InputDecoration(labelText: '...Categoría'),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe seleccionar una categoría';
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
