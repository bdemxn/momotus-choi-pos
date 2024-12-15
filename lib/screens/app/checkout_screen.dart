import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/services/exchange/exchange_value.dart';
import 'package:choi_pos/services/inventory/update_inventory.dart';
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
  String currency = 'Dolares';
  String? referenceCode;
  String? promoCode;
  double discount = 0.0;

  String? _customer;
  num? changeValue;
  double? cashPayment;
  double exchangeRate = 1.0;

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

  // update the new exchange
  Future<void> updateExchangeRate() async {
    final rate = await fetchExchangeRate();
    if (rate != null) {
      setState(() {
        exchangeRate = rate;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tasa de cambio actualizada correctamente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la tasa de cambio.')),
      );
    }
  }

  void calculateChange(CartProvider cartProvider) {
    double totalInSelectedCurrency = (cartProvider.totalPrice - discount) *
        (currency == 'Cordobas' ? exchangeRate : 1.0);

    if (cashPayment != null && cashPayment! >= totalInSelectedCurrency) {
      setState(() {
        changeValue = cashPayment! - totalInSelectedCurrency;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambio calculado correctamente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'El monto ingresado no es suficiente para cubrir el total.')),
      );
    }
  }

  void confirmPurchase(CartProvider cartProvider) async {
    if (selectedPaymentMethod != 'Efectivo' &&
        (referenceCode == null || referenceCode!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, introduzca el código de referencia.')),
      );
      return;
    }

    try {
      // Obtener el carrito actual desde el CartProvider
      final cartItems = cartProvider.cartItems;

      // Actualizar inventario
      await UpdateInventory.updateInventory(
        cartItems
            .map((cartItem) => InventoryItem(
                  barCode: "",
                  category: "",
                  name: "",
                  price: 0,
                  id: cartItem.item.id,
                  quantity: cartItem.quantity,
                ))
            .toList(),
      );

      // Crear los datos para el reporte de ventas
      final List<Map<String, dynamic>> cartData = cartItems.map((cartItem) {
        return {
          'id': cartItem.item.id,
          'quantity': cartItem.quantity,
        };
      }).toList();

      // Enviar reporte de ventas
      await UpdateInventory.postSalesReport(
        cashier: 'nombre_cajero',
        customer: _customer ?? '',
        paymentRef: referenceCode ?? '',
        cart: cartData,
        promoCode: promoCode ?? '',
        totalPaid: cartProvider.totalPrice - discount,
      );

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra confirmada. ¡Gracias!')),
      );

      // Limpiar el carrito y redirigir
      cartProvider.clearCart();
      context.go('/app');
    } catch (e) {
      // Manejar errores y mostrar mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
                        changeValue = null;
                        cashPayment = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButton<String>(
                    value: currency,
                    items: ['Dolares', 'Cordobas'].map((currencyOption) {
                      return DropdownMenuItem(
                        value: currencyOption,
                        child: Text(currencyOption),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == 'Cordobas') {
                        await updateExchangeRate();
                      }
                      setState(() {
                        currency = value!;
                      });
                    },
                  ),

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

                  if (selectedPaymentMethod == 'Efectivo')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Monto con el que paga',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            cashPayment = double.tryParse(value);
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => calculateChange(cartProvider),
                          child: const Text('Calcular cambio'),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Nombre del cliente'),
                    onChanged: (value) {
                      _customer = value;
                    },
                  ),
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
                    "Total: \$${((cartProvider.totalPrice - discount) * (currency == 'Cordobas' ? exchangeRate : 1.0)).toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (changeValue != null)
                    Text(
                      'Cambio: \$${changeValue!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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
