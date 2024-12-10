import 'package:choi_pos/store/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'Tarjeta';
  String? referenceCode;
  String? promoCode;
  double discount = 0.0;

  void applyPromoCode(CartProvider cartProvider) {
    if (promoCode == 'DESCUENTO10') {
      setState(() {
        discount = cartProvider.totalPrice * 0.10;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Código promocional aplicado: 10% de descuento.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código promocional inválido.')),
      );
    }
  }

  void confirmPurchase(CartProvider cartProvider) {
    if (selectedPaymentMethod != 'Efectivo' &&
        (referenceCode == null || referenceCode!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, introduzca el código de referencia.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra confirmada. ¡Gracias!')),
    );

    cartProvider.clearCart();
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: const Row(
        children: [
          Text('Confirmación de compra'),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: Image(
              image: AssetImage('assets/choi-image.png'),
              height: 30,
            ),
          )
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Carrito (Izquierda)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen del carrito:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartProvider.cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cartItem.item.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  'Precio: \$${cartItem.item.price.toStringAsFixed(2)} x Cantidad: ${cartItem.quantity}'),
                              Text(
                                  'Total: \$${cartItem.totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Opciones de pago y confirmación (Derecha)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona el método de pago:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    items: ['Efectivo', 'Tarjeta', 'Transferencia', 'Mixto']
                        .map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                        referenceCode = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

// Opciones para métodos específicos
                  if (selectedPaymentMethod == 'Tarjeta' ||
                      selectedPaymentMethod == 'Transferencia')
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Código de referencia',
                      ),
                      onChanged: (value) {
                        referenceCode = value;
                      },
                    ),

                  if (selectedPaymentMethod == 'Mixto')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Monto efectivo',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  // Guardar el monto efectivo
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Referencia efectivo',
                                ),
                                onChanged: (value) {
                                  // Guardar referencia efectivo
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Monto tarjeta/transferencia',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  // Guardar monto tarjeta/transferencia
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Referencia tarjeta/transferencia',
                                ),
                                onChanged: (value) {
                                  // Guardar referencia tarjeta/transferencia
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Código promocional'),
                    onChanged: (value) {
                      promoCode = value;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => applyPromoCode(cartProvider),
                    child: const Text('Aplicar código promocional'),
                  ),
                  const Spacer(),
                  Text(
                    'Total: \$${(cartProvider.totalPrice - discount).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => confirmPurchase(cartProvider),
                    child: const Text('Confirmar compra'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
