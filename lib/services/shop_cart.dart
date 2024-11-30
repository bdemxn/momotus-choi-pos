import 'package:choi_pos/models/promo_code.dart';

class ShoppingCart {
  double total = 0.0; // Total inicial del carrito
  final List<CartItem> items = [];

  void addItem(CartItem item) {
    if (item.quantity > 0) {
      items.add(item);
      calculateTotal();
    }
  }

  void calculateTotal() {
    total = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void applyPromoCode(PromoCode promoCode) {
    if (promoCode.type == 'fixed') {
      total -= promoCode.value;
    } else if (promoCode.type == 'percentage') {
      total -= total * (promoCode.value / 100);
    }
    if (total < 0) total = 0; // Asegurar que no haya totales negativos
  }
}

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, required this.quantity});
}
