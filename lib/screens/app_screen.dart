import 'package:choi_pos/auth/auth_services.dart';
import 'package:choi_pos/models/inventory_item.dart';
// import 'package:choi_pos/screens/printing/printing_view.dart';
import 'package:choi_pos/services/inventory/get_inventory.dart';
import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:choi_pos/store/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:choi_pos/services/monthly/monthly_services.dart';
import 'package:choi_pos/services/bundles/get_bundles.dart';
// import 'package:choi_pos/screens/printing/printer_controller.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  // final PrinterController _printerController = PrinterController();
  late TextEditingController _searchController;
  final AuthService _authService = AuthService();
  String selectedView = 'Inventario';

  late InventoryItem examItem;
  late InventoryItem monthlyItem;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    final inventoryService =
        Provider.of<InventoryService>(context, listen: false);
    await inventoryService.fetchInventory();
  }

  Future<void> fetchTournaments() async {
    final tournamentService =
        Provider.of<TournamentServices>(context, listen: false);
    await tournamentService.getTournaments();
  }

  Future<void> fetchBundles() async {
    final bundleService = Provider.of<BundleService>(context, listen: false);
    await bundleService.fetchBundles(); // Usar el nombre correcto de la función
  }

  Future<void> fetchMonthly() async {
    final bundleService = Provider.of<MonthlyServices>(context, listen: false);
    await bundleService.fetchMonthly(); // Usar el nombre correcto de la función
  }

  @override
  Widget build(BuildContext context) {
    final inventoryService = Provider.of<InventoryService>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final tournamentService = Provider.of<TournamentServices>(context);
    final monthlyService =
        Provider.of<MonthlyServices>(context); // 🔥 Agregar esto
    final bundleService =
        Provider.of<BundleService>(context); // 🔥 Agregar esto

    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/choi-image.png'),
          height: 40,
        ),
        leading: IconButton(
            onPressed: () async {
              await _authService.logoutAuthService();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada exitosamente')),
              );

              context.go('/');
              cartProvider.clearCart();
            },
            icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              cartProvider.clearCart();
              cartProvider.clearCustomers();
            },
          )
        ],
      ),
      body: Row(
        children: [
          // Inventory or Tournament List
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Search and Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Buscar por código de barras',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: cartProvider.selectedCategory,
                        items: inventoryService.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            cartProvider.setCategory(value!);
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      // Dropdown for selecting "Examenes" or "Inventario"
                      DropdownButton<String>(
                        value: selectedView,
                        items: const [
                          DropdownMenuItem(
                            value: 'Inventario',
                            child: Text('Inventario'),
                          ),
                          DropdownMenuItem(
                            value: 'Examenes',
                            child: Text('Examenes'),
                          ),
                          DropdownMenuItem(
                            value: 'Bundles',
                            child: Text('Bundles'),
                          ),
                          DropdownMenuItem(
                            value: 'Mensualidades',
                            child: Text('Mensualidades'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedView = value!;
                          });

                          switch (selectedView) {
                            case 'Examenes':
                              fetchTournaments(); // Fetch tournaments when selected.
                              break;
                            case 'Mensualidades':
                              fetchMonthly();
                              break;
                            case 'Bundles':
                              fetchBundles();
                              break;
                            case 'Inventario':
                              fetchInventory();
                              break;
                          }
                        },
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      switch (selectedView) {
                        case 'Inventario':
                          final inventoryItems =
                              inventoryService.filteredInventory(
                            _searchController.text,
                            cartProvider.selectedCategory,
                          );

                          return ListView.builder(
                            itemCount: inventoryItems.length,
                            itemBuilder: (context, index) {
                              final item = inventoryItems[index];
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Text(
                                  'Precio: \$${item.price.toStringAsFixed(2)}\nStock: ${item.quantity}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: () => cartProvider.addToCart(item),
                                ),
                              );
                            },
                          );

                        case 'Examenes':
                          return ListView.builder(
                            itemCount: tournamentService.tournamentList.length,
                            itemBuilder: (context, index) {
                              final tournament =
                                  tournamentService.tournamentList[index];
                              return ListTile(
                                title: Text(tournament['name']),
                                subtitle:
                                    Text('Precio: \$${tournament['price']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () {
                                    final examItem = InventoryItem(
                                      id: tournament['id'],
                                      name: tournament['name'],
                                      price: tournament['price'],
                                      barCode: '',
                                      quantity: 1,
                                      category: 'Exámen',
                                    );
                                    cartProvider.addToCart(examItem);
                                  },
                                ),
                              );
                            },
                          );
                        case 'Bundles':
                          return ListView.builder(
                            itemCount: bundleService.bundles.length,
                            itemBuilder: (context, index) {
                              final bundle = bundleService.bundles[index];
                              return ListTile(
                                title: Text(bundle["name"]),
                                subtitle:
                                    Text('Precio: \$${bundle["total_price"]}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_box),
                                  onPressed: () {
                                    final bundleItem = InventoryItem(
                                      id: "${bundle["id"]["tb"]}:${bundle["id"]["id"]["String"]}",
                                      name: bundle["name"],
                                      price: bundle["total_price"],
                                      barCode: '',
                                      quantity: 1,
                                      category: 'Bundle',
                                    );
                                    print(
                                        "Bundle cargado: ${bundle["name"]} - Precio: ${bundle["total_price"]}");
                                    cartProvider.addToCart(bundleItem);
                                  },
                                ),
                              );
                            },
                          );
                        case 'Mensualidades':
                          return ListView.builder(
                            itemCount: monthlyService.monthlyList.length,
                            itemBuilder: (context, index) {
                              final monthly = monthlyService.monthlyList[index];
                              return ListTile(
                                title: Text(monthly["name"]),
                                subtitle: Text(
                                  'Precio: \$${monthly["price"]}%',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    final mensualidadItem = InventoryItem(
                                      id: monthly["id"],
                                      name: monthly["name"],
                                      price: monthly["price"] ?? 0.0,
                                      barCode: '',
                                      quantity: 1,
                                      category: 'Mensualidad',
                                    );

                                    print(
                                        "Mensualidad seleccionada: ${mensualidadItem.name} - Precio: ${mensualidadItem.price}");
                                    cartProvider.addToCart(mensualidadItem);
                                  },
                                ),
                              );
                            },
                          );
                        case 'OtraVista':
                          return const Center(
                              child: Text('Vista de OtraVista'));

                        default:
                          return const Center(
                              child: Text('Selecciona una vista'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(),

          // Cart
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Carrito'),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                          onPressed: () => context.go('/app/create-customer'),
                          icon: const Icon(Icons.add_reaction_sharp)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                          onPressed: () => context.go('/app/sales'),
                          icon:
                              const Icon(Icons.insert_chart_outlined_outlined)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                          onPressed: () => context.go('/app/payments'),
                          icon: const Icon(Icons.payments_outlined)),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 0),
                    //   child: IconButton(
                    //       onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(builder: (context) => PrintingView(controller: _printerController)),
                    //         );
                    //       },
                    //       icon: const Icon(Icons.print)),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                          onPressed: () => context.go('/app/customers'),
                          icon:
                              const Icon(Icons.supervised_user_circle_rounded)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                          onPressed: () => context.go('/app/create-inventory'),
                          icon: const Icon(Icons.inventory)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              fetchInventory();
                            });
                          },
                          icon: const Icon(Icons.refresh)),
                    )
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.cartItems[index];
                      return ListTile(
                        title: Text(cartItem.item.name),
                        subtitle: Text('Cantidad: ${cartItem.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                cartProvider.removeFromCart(cartItem.item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                cartProvider.deleteItem(cartItem.item);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Summary
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                          'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}'),
                      Text('Artículos: ${cartProvider.totalItems}'),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                              onPressed: () {
                                final cartProvider = Provider.of<CartProvider>(
                                    context,
                                    listen: false);

                                if (cartProvider.cartItems.isNotEmpty) {
                                  context.go('/app/checkout',
                                      extra: selectedView);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'El carrito está vacío. Por favor, agrega al menos un producto.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  Text('Confirmar Compra')
                                ],
                              ))),
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
