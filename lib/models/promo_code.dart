class PromoCode {
  final String code;
  final String type; // "porcentaje" o "fijo"
  final double value;
  bool isActive;

  PromoCode({
    required this.code,
    required this.type,
    required this.value,
    this.isActive = true, // <== active by default
  });

  // Validate if the code is valid
  static bool validatePromoCode(String code) {
    return code.length >= 5;
  }

  // Validate if the code is active
  static bool isPromoCodeActive(PromoCode promoCode) {
    return promoCode.isActive;
  }

  // Apply discount to cart total
  static double applyPromoCode(PromoCode promoCode, double cartTotal) {
    if (promoCode.type == "porcentaje") {
      return cartTotal - (cartTotal * promoCode.value / 100);
    } else if (promoCode.type == "fijo") {
      return cartTotal - promoCode.value;
    }
    return cartTotal;
  }
}
