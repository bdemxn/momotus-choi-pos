import 'package:choi_pos/models/promo_code.dart';
import 'package:choi_pos/services/cart_validation.dart';
import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final List<Map<String, dynamic>> inventory = [
    {
      "id": "1",
      "name": "Producto A",
      "price": 50.0,
      "quantity": 10,
      "category": "Bebidas"
    },
    {
      "id": "2",
      "name": "Producto B",
      "price": 30.0,
      "quantity": 0,
      "category": "Comida"
    },
    {
      "id": "3",
      "name": "Producto C",
      "price": 20.0,
      "quantity": 8,
      "category": "Bebidas"
    },
  ];

  final List<Map<String, dynamic>> cart = [];
  String selectedPaymentMethod = 'Efectivo';
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  PromoCode? appliedPromoCode;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void addToCart(Map<String, dynamic> product) {
    if (!CartValidations.isProductAvailable(product)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Este producto no tiene cantidad disponible')),
      );
      return;
    }

    setState(() {
      cart.add({...product, "quantity": 1});
    });
  }

  double calculateTotal() {
    double total =
        cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    if (appliedPromoCode != null) {
      total = PromoCode.applyPromoCode(appliedPromoCode!, total);
    }
    return total;
  }

  void applyPromoCode() {
    final String code = promoCodeController.text.trim();
    // Simulación de códigos de promoción disponibles
    final promoCodes = [
      PromoCode(code: "PROMO10", type: "porcentaje", value: 10, isActive: true),
      PromoCode(
          code: "DISCOUNT50",
          type: "fijo",
          value: 50,
          isActive: false), // Código inactivo
    ];

    final promoCode = promoCodes.where((p) => p.code == code).isNotEmpty
      ? promoCodes.firstWhere((p) => p.code == code)
      : null;

  // Validar si no se encontró el código o si está inactivo
  if (promoCode == null || !promoCode.isActive) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("El código de promoción no es válido o está inactivo.")),
    );
    return;
  }

  // Aplicar la promoción
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Código aplicado: ${promoCode.code}")),
  );
  }

  void confirmPurchase() {
    if (_formKey.currentState!.validate()) {
      if (CartValidations.isCartEmpty(cart)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("El carrito está vacío")),
        );
        return;
      }

      // Aquí iría la lógica de compra y la actualización del backend

      setState(() {
        cart.clear();
        appliedPromoCode = null;
        promoCodeController.clear();
        referenceController.clear();
        selectedPaymentMethod = 'Efectivo';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra realizada con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cajero')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    const Text("Inventario",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: inventory.length,
                        itemBuilder: (context, index) {
                          final product = inventory[index];
                          return Card(
                            child: ListTile(
                              title: Text(product['name']),
                              subtitle: Text("Precio: \$${product['price']}"),
                              trailing: ElevatedButton(
                                onPressed: () => addToCart(product),
                                child: const Text("Añadir"),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const Text("Carrito",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final item = cart[index];
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
                    Text("Total: \$${calculateTotal().toStringAsFixed(2)}"),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: 'Efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(
                            value: 'Tarjeta', child: Text('Tarjeta')),
                        DropdownMenuItem(
                            value: 'Transferencia',
                            child: Text('Transferencia')),
                      ],
                    ),
                    if (selectedPaymentMethod != 'Efectivo')
                      TextFormField(
                        controller: referenceController,
                        decoration:
                            const InputDecoration(labelText: "Referencia"),
                        validator: (value) {
                          if (!CartValidations.isReferenceValid(
                              value, selectedPaymentMethod)) {
                            return "Debe ingresar una referencia válida.";
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      controller: promoCodeController,
                      decoration: const InputDecoration(
                          labelText: "Código de promoción"),
                    ),
                    ElevatedButton(
                      onPressed: applyPromoCode,
                      child: const Text("Aplicar Promoción"),
                    ),
                    ElevatedButton(
                      onPressed: confirmPurchase,
                      child: const Text("Comprar"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
