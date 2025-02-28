import 'package:choi_pos/store/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectedCustomersView extends StatelessWidget {
  const SelectedCustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        var clients = cartProvider.customers;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Clientes Seleccionados'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => cartProvider.customers.clear(),
            child: const Icon(Icons.clear),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: clients.isEmpty
                ? const Center(child: Text('No hay clientes seleccionados'))
                : ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      var client = clients[index];
                      return ListTile(
                        title: Text(client.fullname),
                        subtitle: Text("ID: ${client.id} | Mensualidad: ${client.monthly}"),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
