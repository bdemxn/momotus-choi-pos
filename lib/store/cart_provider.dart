import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class CartItem {
  final InventoryItem item;
  final String? category;
  int quantity;

  CartItem({required this.item, this.quantity = 1, this.category});

  double get adjustedPrice =>
      item.currency == "C\$" ? item.price / 36.7 : item.price;

  double get totalPrice => adjustedPrice * quantity;
}

class Customer {
  final String id;
  final String fullname;

  Customer({required this.id, required this.fullname});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final List<Customer> _customers = [];
  String _selectedCategory = "Todas";
  final String _currency = "Dolares";
  final double _exchangeRate = 1.0;

  List<CartItem> get cartItems => _cartItems;
  String get currency => _currency;
  double get exchangeRate => _exchangeRate;

  List<Customer> get customers => _customers;

  int get totalCustomers => _customers.length;
  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addToCart(InventoryItem item) {
    final index =
        _cartItems.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (index != -1) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(CartItem(item: item));
    }
    notifyListeners();
  }

  void removeFromCart(InventoryItem item) {
    final index =
        _cartItems.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void deleteItem(InventoryItem item) {
    _cartItems.removeWhere((cartItem) => cartItem.item.id == item.id);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void addCustomer(Customer customer) {
    if (!customers.contains(customer)) {
      customers.add(customer);
      notifyListeners();
    }
  }

  void removeCustomer(String id) {
    _customers.removeWhere((customer) => customer.id == id);
    notifyListeners();
  }

  /// 🔹 **Función para limpiar la lista de clientes**
  void clearCustomers() {
    _customers.clear();
    notifyListeners();
  }

  /// 🔹 **Función para obtener los items de categoría "Mensualidades"**
  int getMonthlyItems() {
    return _cartItems
        .where((cartItem) => cartItem.item.category == "Mensualidad")
        .fold(0, (total, cartItem) => total + cartItem.quantity);
  }

  /// 🔹 **Función para obtener la cantidad de clientes seleccionados**
  int getClientCount() {
    return _customers.length;
  }

  /// 🔹 **Función para añadir un cliente**
  void addClient(Customer client) {
    if (!_customers.any((c) => c.id == client.id)) {
      _customers.add(client);
      notifyListeners();
    }
  }

  /// 🔹 **Función para eliminar un cliente**
  void removeClient(String clientId) {
    _customers.removeWhere((client) => client.id == clientId);
    notifyListeners();
  }

  // 🔹 **Función para calcular el total de mensualidades considerando los clientes seleccionados**
  int getTotalMonthlyPayments() {
    return getMonthlyItems() * getClientCount();
  }

  double get totalPrice => double.parse(_cartItems
      .fold<double>(0.0, (total, cartItem) => total + cartItem.totalPrice)
      .toStringAsFixed(2));
  int get totalItems =>
      _cartItems.fold(0, (total, cartItem) => total + cartItem.quantity);

  double get totalPriceMonthly {
    return double.parse(
      _cartItems.fold<double>(0.0, (total, cartItem) {
        if (cartItem.item.category == 'Mensualidad') {
          return total +
              (cartItem.quantity * cartItem.adjustedPrice * _customers.length);
        } else {
          return total + (cartItem.quantity * cartItem.adjustedPrice);
        }
      }).toStringAsFixed(2),
    );
  }
}
