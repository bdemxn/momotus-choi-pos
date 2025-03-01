import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/store/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddPaymentDialog extends StatelessWidget {
  final String clientName;
  final String monthlyId;
  final String clientId;
  final String monthlyName;

  const AddPaymentDialog({
    super.key,
    required this.clientName,
    required this.monthlyId,
    required this.clientId,
    required this.monthlyName
  });

  void onAddToCart(String client, String monthlyId, int totalMonthsToPay, String monthlyName,
      BuildContext context) {
    double price;
    switch (monthlyName) {
      case 'Mensualidad Standard':
        price = 45;
        break;
      case 'Mensualidad Sabatina Standard':
        price = 40;
        break;
      case 'Mensualidad Sabatina Standard Niños 2-4':
        price = 25;
        break;
      case 'Mensualidad Standard Niños 2-4':
        price = 55;
        break;
      default:
        price = 45;
    }
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final InventoryItem monthlyItem = InventoryItem(
        id: monthlyId,
        name: "Mensualidad para $client",
        price: price,
        barCode: clientId,
        quantity: totalMonthsToPay,
        category: monthlyName,
        currency: "\$");

    cartProvider.cartItems.add(CartItem(
        item: monthlyItem, category: monthlyName, quantity: totalMonthsToPay));
  }

  @override
  Widget build(BuildContext context) {
    int selectedMonths = 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text("Pagar Mensualidad"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nombre del estudiante: $clientName"),
              const SizedBox(height: 10),
              Text("Tipo de mensualidad: $monthlyId"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Meses a pagar:"),
                  DropdownButton<int>(
                    value: selectedMonths,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedMonths = newValue;
                        });
                      }
                    },
                    items: List.generate(12, (index) => index + 1)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value"),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                onAddToCart(clientName, monthlyId, selectedMonths, monthlyName, context);
                context.pushReplacement("/app");
              },
              child: const Text("Añadir al carrito"),
            ),
          ],
        );
      },
    );
  }
}
