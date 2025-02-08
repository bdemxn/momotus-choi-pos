import 'package:choi_pos/services/users/get_users.dart';
import 'package:choi_pos/widgets/users/users_update_form.dart';
import 'package:flutter/material.dart';

class UsersTable extends StatefulWidget {
  final VoidCallback getUsers;
  final List<dynamic> userList;

  const UsersTable({super.key, required this.getUsers, required this.userList});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  final GetUsersService _getUsersService = GetUsersService();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUsersService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      flex: 5,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Imagen')),
              DataColumn(label: Text('Nombre Completo')),
              DataColumn(label: Text('Rol')),
              DataColumn(label: Text('Nombre de Usuario')),
              DataColumn(label: Text('Sucursal')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: widget.userList
                .map(
                  (item) => DataRow(cells: [
                    const DataCell(Image(
                      image: AssetImage('assets/choi-user.png'),
                      height: 40,
                    )),
                    DataCell(Text(item.fullname)),
                    DataCell(Text(item.roles)),
                    DataCell(Text(item.username)),
                    DataCell(Text(item.branch)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditUserFormWidget(user: item),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar Eliminación'),
                                    content: Text(
                                        '¿Estás seguro de que quieres eliminar "${item.fullname}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm ?? false) {
                                await _getUsersService.deleteUser(item.id);
                                setState(() {});
                                widget.getUsers();
                              }
                            },
                          ),
                          IconButton(
                              icon: const Icon(Icons.update,
                                  color: Colors.blueAccent),
                              onPressed: () async => {
                                    await _showChangePasswordDialog(
                                        context, item.fullname, item.id)
                                  }),
                        ],
                      ),
                    ),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(
      BuildContext context, String fullname, String userId) async {
    final formKey = GlobalKey<FormState>(); // Llave local del formulario

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar cambio de contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('¿Estás seguro de cambiar la contraseña de "$fullname"?'),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pon una contraseña';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _repeatPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Repite la contraseña',
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite nuevamente la contraseña';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                  widget.getUsers();
                }
              },
              child: const Text('Cambiar contraseña'),
            ),
          ],
        );
      },
    );

    // Limpieza después de cerrar el diálogo
    _newPasswordController.clear();
    _repeatPasswordController.clear();

    if (confirm ?? false) {
      await _getUsersService.updateUserPassword(
        _newPasswordController.text,
        userId,
      );
      setState(() {});
    }
  }
}
