import 'package:choi_pos/models/inventory_item.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final List<InventoryItem> cart;

  const CheckoutScreen({super.key, required this.cart});

  double get totalPrice =>
      cart.fold(0.0, (sum, item) => sum + item.price);

  int get totalItems => cart.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Artículos en el carrito:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Precio: \$${item.price.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Total de artículos: $totalItems'),
            Text('Total a pagar: \$${totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes manejar la confirmación de la compra
                  Navigator.pop(context);
                },
                child: const Text('Confirmar compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
