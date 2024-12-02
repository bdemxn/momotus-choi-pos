import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/screens/app/checkout_screen.dart';
import 'package:choi_pos/services/get_inventory.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final InventoryService _inventoryService = InventoryService();
  final List<InventoryItem> _cart = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    await _inventoryService.fetchInventory();
    setState(() {});
  }

  void _addToCart(InventoryItem item) {
    setState(() {
      _cart.add(item);
    });
  }

  double get totalPrice => _cart.fold(0.0, (sum, item) => sum + item.price);

  int get totalItems => _cart.length;

  void _goToCheckout() {
    /*if (_cart.isEmpty) {
      // Mostrar un mensaje si el carrito está vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'El carrito está vacío. Agrega artículos antes de continuar.'),
        ),
      );
      return;
    }*/

    bool hasInsufficientStock = _cart.any((item) =>
        _inventoryService.inventory
            .firstWhere((invItem) => invItem.id == item.id)
            .quantity <
        1);

    if (hasInsufficientStock) {
      // Mostrar un mensaje si hay artículos sin stock suficiente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uno o más artículos no tienen stock suficiente.'),
        ),
      );
      return;
    }

    // Si pasa las validaciones, navegar al CheckoutScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: _cart, onCheckoutComplete: () => setState(() {
          _cart.clear();
        }),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredInventory = _inventoryService.inventory
        .where((item) =>
            item.barCode.contains(_searchQuery) || _searchQuery.isEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Cajero'),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Image(image: AssetImage('assets/choi-image.png'), height: 30,),
            )
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Row(
        children: [
          // Sección izquierda: Inventario y búsqueda
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por código de barras',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredInventory.length,
                    itemBuilder: (context, index) {
                      final item = filteredInventory[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stock: ${item.quantity}'),
                              Text(
                                  'Precio: \$${item.price.toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () => _addToCart(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1.0),
          // Sección derecha: Carrito
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Carrito de Compras',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle:
                            Text('Precio: \$${item.price.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total de artículos: $totalItems'),
                      Text('Total a pagar: \$${totalPrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _goToCheckout,
                          child: const Text('Confirmar Compra'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
