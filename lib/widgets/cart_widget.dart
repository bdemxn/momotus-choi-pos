import 'package:choi_pos/services/cart_validation.dart';
import 'package:flutter/material.dart';

class CartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String selectedPaymentMethod;
  final dynamic applyPromoCode;
  final dynamic promoCodeController;
  final dynamic referenceController;
  final dynamic confirmPurchase;
  final ValueChanged<String> onPaymentMethodChanged;

  const CartWidget({
    super.key,
    required this.cart,
    required this.selectedPaymentMethod,
    required this.promoCodeController,
    required this.referenceController,
    required this.confirmPurchase,
    required this.applyPromoCode,
    required this.onPaymentMethodChanged,
  });

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Carrito",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              final item = widget.cart[index];
              return Card(
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text("Cantidad: ${item['quantity']}"),
                  trailing: Text("Subtotal: \$${item['price']}"),
                ),
              );
            },
          ),
        ),
        Text(
          "Total: \$${widget.cart.fold(0.0, (sum, item) => sum + item['price']).toStringAsFixed(2)}",
        ),
        DropdownButtonFormField<String>(
          value: widget.selectedPaymentMethod,
          onChanged: (value) {
            if (value != null) {
              widget.onPaymentMethodChanged(value); // Llama al callback
            }
          },
          items: const [
            DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
            DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
            DropdownMenuItem(
              value: 'Transferencia',
              child: Text('Transferencia'),
            ),
          ],
        ),
        if (widget.selectedPaymentMethod != 'Efectivo')
          TextFormField(
            controller: widget.referenceController,
            decoration: const InputDecoration(labelText: "Referencia"),
            validator: (value) {
              if (!CartValidations.isReferenceValid(
                  value, widget.selectedPaymentMethod)) {
                return "Debe ingresar una referencia válida.";
              }
              return null;
            },
          ),
        TextFormField(
          controller: widget.promoCodeController,
          decoration: const InputDecoration(labelText: "Código de promoción"),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: widget.confirmPurchase,
                child: const Text("Comprar"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: widget.applyPromoCode,
                child: const Text("Aplicar Promoción"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
