import 'package:choi_pos/services/users/get_users.dart';
import 'package:flutter/material.dart';

class UsersTable extends StatefulWidget {
  const UsersTable({super.key});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  final GetUsersService _getUsersService = GetUsersService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    setState(() {
      _getUsersService.fetchUsers();
    });
  }

  Future<void> _deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _getUsersService.deleteUser(id);
      print(id);
      _fetchUsers(); // Refresca la lista tras eliminar
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsersService.fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final usersList = _getUsersService.userList;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Imagen')),
                DataColumn(label: Text('Nombre Completo')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Nombre de Usuario')),
                DataColumn(label: Text('Sucursal')),
                DataColumn(label: Text('Acciones')), // Nueva columna
              ],
              rows: usersList
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
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>  _deleteUser(item.id),
                        ),
                      ),
                    ]),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
