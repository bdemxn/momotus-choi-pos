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

    // Fetching:
    _getUsersService.fetchUsers();
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
                DataColumn(label: Text('')),
                DataColumn(label: Text('Nombre Completo')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Nombre de Usuario')),
                DataColumn(label: Text('Sucursal')),
              ],
              rows: usersList
                  .map(
                    (item) => DataRow(cells: [
                      const DataCell(Image(image: AssetImage('assets/choi-user.png'), height: 40,) as Widget),
                      DataCell(Text(item.fullname)),
                      DataCell(Text(item.roles)),
                      DataCell(Text(item.username)),
                      DataCell(Text(item.branch)),
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
