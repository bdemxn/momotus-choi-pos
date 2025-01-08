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
    monthsStatus = widget.months.map((key, value) => MapEntry(key, value));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Pago - ${widget.clientName}'),
      content: SingleChildScrollView(
        child: Column(
          children: orderedMonths.map((month) {
            return CheckboxListTile(
              title: Text(month),
              value: monthsStatus[month],
              onChanged: (bool? value) {
                setState(() {
                  monthsStatus[month] = value ?? false;
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
