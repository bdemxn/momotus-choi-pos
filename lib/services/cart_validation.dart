import 'package:choi_pos/models/inventory_item.dart';
import 'package:choi_pos/models/promo_code.dart';

class CartValidations {
  // Validate if the cart isn't empty
  static bool isCartEmpty(List<InventoryItem> cart) {
    return cart.isEmpty;
  }

  // Validate if a product has available quantity
  static bool isProductAvailable(InventoryItem product) {
    return product.quantity > 0;
  }

  // Validate if the reference number is valid
  static bool isReferenceValid(String? reference, String paymentMethod) {
    if (paymentMethod == 'Tarjeta' || paymentMethod == 'Transferencia') {
      return reference != null && reference.isNotEmpty;
    }
    return true;
  }

  // Validate the promocode
  static String? validatePromoCodeInput(String code, PromoCode? promoCode) {
    if (!PromoCode.validatePromoCode(code)) {
      return "El código debe tener al menos 5 caracteres.";
    }
    if (promoCode == null) {
      return "El código de promoción no es válido.";
    }
    if (!PromoCode.isPromoCodeActive(promoCode)) {
      return "El código de promoción no está activo.";
    }
    return null;
  }
}
