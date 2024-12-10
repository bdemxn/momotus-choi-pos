import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class CartItem {
  final InventoryItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get totalPrice => item.price * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  String _selectedCategory = "Todas";

  List<CartItem> get cartItems => _cartItems;

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

  double get totalPrice =>
      _cartItems.fold(0, (total, cartItem) => total + cartItem.totalPrice);

  int get totalItems =>
      _cartItems.fold(0, (total, cartItem) => total + cartItem.quantity);
}
