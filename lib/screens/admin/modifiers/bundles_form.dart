import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BundlesFormWidget extends StatefulWidget {
  const BundlesFormWidget({super.key});

  @override
  State<BundlesFormWidget> createState() => _BundlesFormWidgetState();
}

class _BundlesFormWidgetState extends State<BundlesFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<ProductInBundle> _selectedProducts = [];

  bool _isLoading = false;
  List<Product> _inventory = [];
  List<Product> _filteredInventory = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse('http://216.238.86.5:8000/admin/inventory'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _inventory = data.map((item) => Product.fromJson(item)).toList();
          _filteredInventory = _inventory;
        });
      } else {
        throw Exception('Error al cargar el inventario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final bundleData = {
        'name': _nameController.text,
        'products': _selectedProducts.map((p) => p.toJson()).toList(),
      };

      try {
        setState(() => _isLoading = true);
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('authToken');

        final response = await http.post(
          Uri.parse('http://216.238.86.5:8000/admin/bundles'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(bundleData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bundle creado exitosamente')),
          );
          _formKey.currentState!.reset();
          _selectedProducts.clear();
        } else {
          throw Exception('Error al crear el bundle');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showProductSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        _filteredInventory = _inventory
                            .where((product) => product.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredInventory.length,
                      itemBuilder: (context, index) {
                        final product = _filteredInventory[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('ID: ${product.id}'),
                          onTap: () {
                            setState(() {
                              _selectedProducts.add(ProductInBundle(
                                id: product.id,
                                name: product.name,
                                quantity: 1,
                                discount: 0.0,
                              ));
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Bundle'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
                decoration: const InputDecoration(labelText: 'Nombre del Bundle'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showProductSelectionModal,
                child: const Text('Agregar Producto'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _selectedProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${product.id}'),
                          TextFormField(
                            initialValue: product.quantity.toString(),
                            decoration: const InputDecoration(labelText: 'Cantidad'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                product.quantity = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                          TextFormField(
                            initialValue: product.discount.toStringAsFixed(2),
                            decoration: const InputDecoration(labelText: 'Descuento (%)'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                product.discount = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedProducts.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Crear Bundle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ProductInBundle {
  final String id;
  final String name;
  int quantity;
  double discount;

  ProductInBundle({
    required this.id,
    required this.name,
    required this.quantity,
    required this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'discount': discount,
    };
  }
}
