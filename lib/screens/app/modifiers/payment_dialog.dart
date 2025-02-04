import 'package:choi_pos/services/payments/payment_services.dart';
import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final String clientName;
  final Map<String, dynamic> months;
  final String id;

  const PaymentDialog({
    super.key,
    required this.clientName,
    required this.months,
    required this.id
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late Map<String, bool> monthsStatus;
  final PaymentServices _paymentServices = PaymentServices();

  final List<String> orderedMonths = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    monthsStatus = {};

    // Ensure widget.months is treated as a List<dynamic> safely
    List<dynamic> monthsList = (widget.months is List) ? widget.months as List<dynamic> : [];

    // Convert the list of months into a Map<String, dynamic> for quick lookup
    Map<String, dynamic> monthsMap = {
      for (var monthData in monthsList) if (monthData is Map<String, dynamic>) monthData["month"]: monthData
    };

    for (var month in orderedMonths) {
      if (monthsMap.containsKey(month)) {
        monthsStatus[month] = monthsMap[month]["paid"] ?? false;
      } else {
        monthsStatus[month] = false; // Mark as pending if no payment is recorded
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Pago - ${widget.clientName}'),
      content: SingleChildScrollView(
        child: Column(
          children: orderedMonths.map((month) {
            var paymentDetails = widget.months.entries.firstWhere(
              (entry) => entry.value["month"] == month,
              orElse: () => MapEntry("", {}),
            ).value;

            bool isPaid = paymentDetails.isNotEmpty && paymentDetails["paid"] == true;
            return ListTile(
              title: Text(month),
              subtitle: isPaid
                  ? Text("Pagado el ${paymentDetails["payment_date"]} - ${paymentDetails["method"]} - \$${paymentDetails["how_much"]}")
                  : const Text("Pendiente"),
              trailing: Icon(
                isPaid ? Icons.check_circle : Icons.cancel,
                color: isPaid ? Colors.green : Colors.red,
              ),
            );
        }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            _paymentServices.putPayment(monthsStatus, widget.id);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
