import 'package:choi_pos/services/create_category.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryFormWidget extends StatefulWidget {
  const CategoryFormWidget({super.key});

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String categoryData = _nameController.text;

      try {
        setState(() => _isLoading = true);
        await createCategory(categoryData);
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
          title: const Text('Crea una categoría para el inventario'),
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
                    const InputDecoration(labelText: 'Nombre de la categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de categoría no puede estar vacío';
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
                        'Crear Categoría',
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
