import 'package:choi_pos/services/users/get_users.dart';
import 'package:choi_pos/widgets/admin/sidebar_admin.dart';
import 'package:choi_pos/widgets/users/users_table.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final GetUsersService _userServices = GetUsersService();
  List<dynamic> _userList = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    await _userServices.fetchUsers();
    setState(() {
      _userList = _userServices.userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [SidebarAdmin()],
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuarios',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Todos los usuarios que has creado:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () => fetchUsers(),
                            child: const Icon(Icons.restore_outlined,
                                color: Colors.lightBlue)),
                        ElevatedButton(
                          onPressed: () =>
                              context.go('/admin/users/create-user'),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.lightBlue,
                              ),
                              Text(
                                'Añadir usuario',
                                style: TextStyle(color: Colors.lightBlue),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // DataTable:
                  UsersTable(
                    getUsers: fetchUsers,
                    userList: _userList,
                  )
                ],
              ))
        ],
      ),
    );
  }
}
