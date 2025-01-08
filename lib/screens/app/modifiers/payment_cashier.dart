import 'package:choi_pos/widgets/payments/payment_table.dart';
import 'package:flutter/material.dart';

class CashierPaymentsScreen extends StatelessWidget {
  const CashierPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pagos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Pagos de tus clientes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, left: 40),
                      child: PaymentTable(),
                    ),
                  )
                ]
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.pop(context)
        },
        child: const Icon(Icons.keyboard_return),
      ),
    );
  }
}
