import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/services/exchange/exchange_value.dart';
import 'package:choi_pos/services/inventory/update_inventory.dart';
import 'package:choi_pos/store/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:choi_pos/screens/printing/printer_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final PrinterController printerController;
  
  const CheckoutScreen({super.key, required this.printerController});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late SharedPreferences prefs;
  String selectedPaymentMethod = 'Efectivo';
  String currency = 'Dolares';
  String? referenceCode;
  String? promoCode;
  double discount = 0.0;

  String? _customer;
  num? changeValue;
  double? cashPayment;
  double exchangeRate = 1.0;

  List<String> mixReference = [];
  List<dynamic> availablePromoCodes = [];

  Map<String, dynamic> buildReceiptData(CartProvider cartProvider) {
    final total = (cartProvider.totalPrice - discount);
    return {
      'customer': _customer ?? 'Cliente no especificado',
      'items': cartProvider.cartItems.map((item) {
        return {
          'name': item.item.name,
          'quantity': item.quantity,
          'price': item.item.price.toStringAsFixed(2),
          'total': item.totalPrice.toStringAsFixed(2),
        };
      }).toList(),
      'discount': discount.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
      'payment_method': selectedPaymentMethod,
      'currency': currency,
      'change': changeValue?.toStringAsFixed(2) ?? '0.00',
    };
  }

  Future<void> fetchPromoCodes() async {
    const String apiUrl = 'http://216.238.86.5:8000/cashier/promos';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          availablePromoCodes = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to fetch promo codes');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar códigos promocionales: $e')),
      );
      print(e);
    }
  }

  void applyPromoCode(CartProvider cartProvider) {
    if (promoCode != null) {
      // Buscar el código promocional en la lista
      final promoDetails = availablePromoCodes.firstWhere(
        (promo) => promo['code'] == promoCode,
        orElse: () => null, // Retorna null si no se encuentra el código
      );

      if (promoDetails != null) {
        setState(() {
          discount = promoDetails['discount_type'] == 'porcentaje'
              ? cartProvider.totalPrice * (promoDetails['discount_value'] / 100)
              : promoDetails['discount_value'].toDouble();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Código promocional aplicado: ${promoDetails['discount_type'] == 'porcentaje' ? '${promoDetails['discount_value']}% de descuento' : '\$${promoDetails['discount_value']} de descuento'}.',
            ),
          ),
        );
      } else {
        // Código promocional inválido
        setState(() {
          discount = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código promocional inválido.')),
        );
      }
    } else {
      // Si no hay código ingresado
      setState(() {
        discount = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un código promocional.')),
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

  Future<double> updateExchangeRateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final storedDate = prefs.getString('exchangeRateDate');

    // Si la tasa ya está actualizada hoy, retorna el valor almacenado
    if (storedDate == today) {
      return prefs.getDouble('exchangeRate') ?? 36.5;
    }

    // Realiza un fetch si no está actualizada
    final rate = await fetchExchangeRate();
    if (rate != null) {
      await saveExchangeRate(rate);
      return rate;
    }

    // Si no se pudo obtener una tasa nueva, devuelve un valor predeterminado
    return 36.61;
    }

    void calculateChange(CartProvider cartProvider) {
    // Verifica que cashPayment no sea nulo y sea mayor que 0
    if (cashPayment == null || cashPayment! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido para el pago.')),
      );
      return;
    }

    // Calcula el total en la moneda seleccionada
    final totalInSelectedCurrency = double.tryParse(
      ((cartProvider.totalPrice - discount) *
              (currency == 'Cordobas' ? exchangeRate : 1.0))
          .toStringAsFixed(2),
    );

    // Valida que el total en la moneda seleccionada sea válido
    if (totalInSelectedCurrency == null || totalInSelectedCurrency <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error en el cálculo del total. Por favor, verifica.')),
      );
      return;
    }

    // Valida si el monto ingresado es suficiente para cubrir el total
    if (cashPayment! >= totalInSelectedCurrency) {
      setState(() {
        changeValue = double.parse(
          (cashPayment! - totalInSelectedCurrency).toStringAsFixed(2),
        );
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    if (widget.printerController.connectedPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ninguna impresora conectada.')),
      );
      widget.printerController.debugPrinterState(); // Para depurar
      return;
    }
    if ((selectedPaymentMethod == 'Tarjeta' || selectedPaymentMethod == 'Transferencia') &&
        (referenceCode == null || referenceCode!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduzca el código de referencia.')),
      );
      return;
    }

    try {
      // Obtener el carrito actual desde el CartProvider
      final cartItems = cartProvider.cartItems;
      final String kindOfArticle = GoRouterState.of(context).extra! as String;

      // Actualizar inventario
      await UpdateInventory.updateInventory(
          cartItems
              .map((cartItem) => InventoryItem(
                    barCode: "",
                    category: "",
                    name: cartItem.item.name,
                    price: 0,
                    id: cartItem.item.id,
                    quantity: cartItem.quantity,
                  ))
              .toList(),
          selectedView: kindOfArticle);

      final prefs = await SharedPreferences.getInstance();
      final String? currentUser = prefs.getString('fullname');

      // Crear los datos para el reporte de ventas
      final List<Map<String, dynamic>> cartData = cartItems.map((cartItem) {
        return {
          'id': cartItem.item.id,
          'quantity': cartItem.quantity,
        };
      }).toList();

      // Enviar reporte de ventas
      await UpdateInventory.postSalesReport(
          cashier: currentUser!,
          customer: _customer ?? '',
          paymentRef: selectedPaymentMethod == 'Mixto'
              ? mixReference.join(', ')
              : referenceCode ?? '',
          cart: cartData,
          promoCode: promoCode ?? '',
          totalPaid: currency == 'Dolares'
              ? cartProvider.totalPrice - discount
              : (cartProvider.totalPrice - discount) * 36.79,
          currency: currency == 'Dolares' ? 'USD' : 'NIO',
          type: selectedPaymentMethod,
          change: changeValue ?? 0,
          printerController: widget.printerController,
          context: context,);

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
    } finally {
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el indicador
    }
  }

  @override
  void initState() {
    super.initState();
    // Llama a _loadSharedPreferences para inicializar las preferencias
    _loadSharedPreferences();
    
    // Restaurar conexión de impresora al iniciar
    widget.printerController.restoreConnectedPrinter().then((_) {
      if (widget.printerController.connectedPrinter != null) {
        print("Conexión restaurada: ${widget.printerController.connectedPrinter}");
      }
    });
  }
  Future<void> _loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
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
                                'Precio: ${cartProvider.currency == "Dolares" ? "\$" : "C\$"}${cartItem.item.price.toStringAsFixed(2)} x Cantidad: ${cartItem.quantity}',
                              ),
                              Text(
                                'Total: ${cartProvider.currency == "Dolares" ? "\$" : "C\$"}${cartItem.totalPrice.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final newPrice = await _showEditPriceDialog(
                                      context, cartItem.item.price);
                                  if (newPrice != null) {
                                    cartProvider.updateItemPrice(
                                        cartItem.item.id, newPrice);
                                  }
                                },
                                child: const Text('Editar Precio'),
                              ),
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
                        final rate = await updateExchangeRateIfNeeded();
                        if (rate != null) {
                          cartProvider.updateCurrency('Cordobas', exchangeRate);
                        }
                      } else if (value == 'Dolares') {
                        cartProvider.updateCurrency(
                            'Dolares', 1); // Restaurar precios a dólares
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

                  if (selectedPaymentMethod == 'Mixto')
                    Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Referencia 1',
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (mixReference.isNotEmpty) {
                                mixReference[0] = value;
                              } else {
                                mixReference.add(value);
                              }
                            });
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Referencia 2',
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (mixReference.length >= 2) {
                                mixReference[1] = value;
                              } else {
                                mixReference.add(value);
                              }
                            });
                          },
                        ),
                      ],
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
                    "Total: ${currency == 'Cordobas' ? "C\$" : "\$"} ${((cartProvider.totalPrice - discount).toStringAsFixed(2))}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (changeValue != null)
                    Text(
                      'Cambio: ${currency == 'Cordobas' ? "C\$" : "\$"} ${changeValue!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      confirmPurchase(cartProvider);
                    },
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

  Future<double?> _showEditPriceDialog(
      BuildContext context, double currentPrice) async {
    final TextEditingController controller =
        TextEditingController(text: '0'); // Valor inicial para el descuento
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aplicar descuento'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Descuento a aplicar', hintText: 'Ejemplo: 5'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? discount = double.tryParse(controller.text);
                if (discount != null) {
                  final double newPrice = currentPrice - discount;
                  if (newPrice >= 0) {
                    Navigator.of(context).pop(newPrice);
                  } else {
                    // Mostrar mensaje si el descuento es mayor que el precio actual
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El descuento no puede ser mayor que el precio actual.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
