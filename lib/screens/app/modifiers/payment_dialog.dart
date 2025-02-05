import 'package:choi_pos/services/payments/payment_services.dart';
import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final String clientName;
  final Map<String, dynamic> months;
  final String id;

  const PaymentDialog(
      {super.key,
      required this.clientName,
      required this.months,
      required this.id});

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

    // Extraer correctamente la lista de meses desde el Map "widget.months"
    List<Map<String, dynamic>> monthsList = [];

    if (widget.months.containsKey("months")) {
      var extractedMonths = widget.months["months"];
      if (extractedMonths is List) {
        monthsList = List<Map<String, dynamic>>.from(extractedMonths);
      }
    }

    for (var month in orderedMonths) {
      var paymentDetails = monthsList.firstWhere(
        (monthData) => monthData["month"] == month,
        orElse: () => <String,
            dynamic>{}, // Si no encuentra el mes, retorna un mapa vacío
      );

      monthsStatus[month] =
          paymentDetails.isNotEmpty ? paymentDetails["paid"] ?? false : false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Pago - ${widget.clientName}'),
      content: SingleChildScrollView(
        child: Column(
          children: orderedMonths.map((month) {
            List<Map<String, dynamic>> monthsList = [];

            if (widget.months.containsKey("months")) {
              var extractedMonths = widget.months["months"];
              if (extractedMonths is List) {
                monthsList = List<Map<String, dynamic>>.from(extractedMonths);
              }
            }

            var paymentDetails = monthsList.firstWhere(
              (monthData) => monthData["month"] == month,
              orElse: () => <String, dynamic>{},
            );

            bool isPaid =
                paymentDetails.isNotEmpty && paymentDetails["paid"] == true;

            return ListTile(
              title: Text(month),
              subtitle: isPaid
                  ? Text(
                      "Pagado el ${paymentDetails["payment_date"]} - ${paymentDetails["method"]} - \$${paymentDetails["how_much"]}",
                    )
                  : const Text("Pendiente"),
              trailing: Icon(
                isPaid ? Icons.check_circle : Icons.cancel,
                color: isPaid ? Colors.green : Colors.red,
              ),
              onTap: () {
                setState(() {
                  monthsStatus[month] = !monthsStatus[month]!;
                });
              },
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
