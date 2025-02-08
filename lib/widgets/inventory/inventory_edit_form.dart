import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/services/category/get_categories.dart';
import 'package:choi_pos/services/inventory/get_inventory.dart';
import 'package:flutter/material.dart';

class InventoryEditFormWidget extends StatefulWidget {
  final InventoryItem item;

  const InventoryEditFormWidget({required this.item, super.key});

  @override
  State<InventoryEditFormWidget> createState() =>
      _InventoryEditFormWidgetState();
}

class _InventoryEditFormWidgetState extends State<InventoryEditFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _barcodeController;
  late TextEditingController _quantityController;
  late String? _selectedCategory;

  List<String> _categories = [];

  bool _isFetchingCategories = false;
  bool _isLoading = false;

  Future<void> _fetchCategories() async {
    setState(() {
      _isFetchingCategories = true;
    });

    try {
      final categories = await fetchCategories();
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;

        print(_categories);
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

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController =
        TextEditingController(text: widget.item.price.toString());
    _barcodeController = TextEditingController(text: widget.item.barCode);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _selectedCategory = widget.item.category;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedItem = InventoryItem(
        id: widget.item.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        barCode: _barcodeController.text,
        quantity: int.parse(_quantityController.text),
        category: _selectedCategory!,
        currency: ""
      );

      try {
        setState(() => _isLoading = true);
        await InventoryService().updateInventoryItem(updatedItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto actualizado exitosamente')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'El nombre no puede estar vacío'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Debe ser un número válido'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration:
                    const InputDecoration(labelText: 'Código de barras'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                        ? 'Debe ser un número válido'
                        : null,
              ),
              const SizedBox(height: 16),
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Guardar Cambios'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
