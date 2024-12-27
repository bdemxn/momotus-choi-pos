import 'package:choi_pos/models/user.dart';
import 'package:choi_pos/services/users/update_user.dart';
import 'package:flutter/material.dart';

class EditUserFormWidget extends StatefulWidget {
  final User user;

  const EditUserFormWidget({super.key, required this.user});

  @override
  State<EditUserFormWidget> createState() => _EditUserFormWidgetState();
}

class _EditUserFormWidgetState extends State<EditUserFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullnameController;
  late TextEditingController _usernameController;
  late TextEditingController _branchController;
  String _selectedRole = 'usuario';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.user.fullname);
    _usernameController = TextEditingController(text: widget.user.username);
    _branchController = TextEditingController(text: widget.user.branch);
    _selectedRole = widget.user.roles;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> updatedUserData = {
        'fullname': _fullnameController.text,
        'username': _usernameController.text,
        'branch': _branchController.text,
        'roles': _selectedRole,
      };

      try {
        setState(() => _isLoading = true);
        await UpdateUserService.updateUser(widget.user.id, updatedUserData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
        Navigator.of(context).pop(); // Vuelve a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        title: const Text('Editar Usuario'),
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
              const Center(
                child: Image(
                  image: AssetImage('assets/choi-user.png'),
                  height: 100,
                ),
              ),
              TextFormField(
                controller: _fullnameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                    labelText: 'Usuario (ej. juan.sanchez)'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El usuario no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La sucursal no puede estar vacía';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Actualizar Usuario'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
