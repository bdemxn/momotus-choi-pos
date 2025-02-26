import 'package:flutter/material.dart';

class PaymentDialog extends StatelessWidget {
  final String id;
  final String clientName;
  final List<dynamic> months; // Se cambia a List<dynamic> para evitar el error

  const PaymentDialog({
    super.key,
    required this.id,
    required this.clientName,
    required this.months,
  });

  static const Map<String, int> monthOrder = {
    "Enero": 1,
    "Febrero": 2,
    "Marzo": 3,
    "Abril": 4,
    "Mayo": 5,
    "Junio": 6,
    "Julio": 7,
    "Agosto": 8,
    "Septiembre": 9,
    "Octubre": 10,
    "Noviembre": 11,
    "Diciembre": 12,
  };

  @override
  Widget build(BuildContext context) {
    // Convertimos `months` en una lista de mapas correctamente tipada
    List<Map<String, dynamic>> sortedMonths = months
        .map((e) =>
            e as Map<String, dynamic>) // Asegurar que cada elemento sea un Map
        .toList()
      ..sort(
          (a, b) => monthOrder[a['month']]!.compareTo(monthOrder[b['month']]!));

    return AlertDialog(
      title: Text("Pagos de $clientName"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sortedMonths.length,
          itemBuilder: (context, index) {
            final month = sortedMonths[index];
            return ListTile(
              title: Text(
                month['month'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                month['paid']
                    ? "Pagado el ${month['payment_date']} (${month['method']})"
                    : "Pendiente de pago",
                style: TextStyle(
                  color: month['paid'] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                month['paid'] ? Icons.check_circle : Icons.cancel,
                color: month['paid'] ? Colors.green : Colors.red,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
