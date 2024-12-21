import 'package:choi_pos/widgets/reports/report_card_cashier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsScreenCashier extends StatelessWidget {
  const ReportsScreenCashier({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => context.go('/app'), child: const Icon(Icons.keyboard_return),),
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
                      'Reportería',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Toda tu data de ventas aquí',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, left: 40),
                        child: ReportCardCashier(),
                      ),
                    )
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
