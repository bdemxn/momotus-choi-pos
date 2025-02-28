import 'package:flutter/material.dart';

class AddPaymentDialog extends StatelessWidget {
  final String clientName;
  final String monthlyId;
  final Function() onAddToCart;

  const AddPaymentDialog({
    super.key,
    required this.clientName,
    required this.monthlyId,
    required this.onAddToCart,
  });

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
                onAddToCart();
                Navigator.of(context).pop();
              },
              child: const Text("Añadir al carrito"),
            ),
          ],
        );
      },
    );
  }
}
