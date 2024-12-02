import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/models/promo_code.dart';
import 'package:choi_pos/services/update_inventory.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<InventoryItem> cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  
  bool? isLoading;
  final _formKey = GlobalKey<FormState>();
  String paymentMethod = 'Efectivo';
  String? referenceCode;
  String? promoCodeInput;
  PromoCode? appliedPromoCode;

  final promoCodes = [
    PromoCode(code: 'PROMO10', type: 'porcentaje', value: 10),
    PromoCode(code: 'DISCOUNT20', type: 'fijo', value: 20),
    PromoCode(code: 'SALE30', type: 'porcentaje', value: 30),
  ];

  double get totalPrice {
    double cartTotal = widget.cart.fold(0.0, (sum, item) => sum + item.price);
    if (appliedPromoCode != null &&
        PromoCode.isPromoCodeActive(appliedPromoCode!)) {
      cartTotal = PromoCode.applyPromoCode(appliedPromoCode!, cartTotal);
    }
    return cartTotal;
  }

  int get totalItems => widget.cart.length;

  Future<void> _submitCheckout() async {
  if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState?.save();

    if ((paymentMethod == 'Transferencia' || paymentMethod == 'Tarjeta') &&
        (referenceCode == null || referenceCode!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código de referencia es obligatorio')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Activar indicador de carga
    });

    try {
      // Actualizar inventario
      await UpdateInventory.updateInventory(widget.cart);

      // Enviar reporte de ventas
      final products = widget.cart.map((item) {
        return {'id': item.id, 'quantity': item.quantity};
      }).toList();

      await UpdateInventory.postSalesReport(
        cashier: 'NombreDelCajero',
        customer: 'Cliente Generico',
        paymentRef: referenceCode ?? 'N/A',
        products: products,
        promoCode: appliedPromoCode?.code ?? 'Ninguno',
        totalPaid: totalPrice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra realizada con éxito')),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false; // Desactivar indicador de carga
      });
    }
  }
}
  // Submit changes🚀

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Resumen de compra'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Artículos en el carrito:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.cart.length,
                  itemBuilder: (context, index) {
                    final item = widget.cart[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle:
                          Text('Precio: \$${item.price.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              const Divider(),
              Text('Total de artículos: $totalItems'),
              Text('Total a pagar: \$${totalPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              if (appliedPromoCode != null)
                Text(
                  'Código aplicado: ${appliedPromoCode!.code} (${appliedPromoCode!.type == 'porcentaje' ? '${appliedPromoCode!.value}% de descuento' : '\$${appliedPromoCode!.value} de descuento'})',
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Método de Pago',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      items: const [
                        DropdownMenuItem(
                            value: 'Efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(
                            value: 'Transferencia',
                            child: Text('Transferencia')),
                        DropdownMenuItem(
                            value: 'Tarjeta', child: Text('Tarjeta')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                          referenceCode = null; // Reinicia la referencia
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (paymentMethod == 'Transferencia' ||
                        paymentMethod == 'Tarjeta')
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Código de Referencia',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) => referenceCode = value,
                        validator: (value) {
                          if (paymentMethod != 'Efectivo' &&
                              (value == null || value.isEmpty)) {
                            return 'El código de referencia es obligatorio';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Código de Promoción',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Código de Promoción (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => promoCodeInput = value,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Aquí puedes manejar la confirmación de la compra
                              _submitCheckout();
                            },
                            child: const Text('Confirmar compra'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ])));
  }
}
