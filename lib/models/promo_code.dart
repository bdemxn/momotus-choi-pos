class PromoCode {
  final String code;
  final String discountType;
  final double discountValue;
  final bool active;

  PromoCode({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.active,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code'],
      discountType: json['discount_type'],
      discountValue: (json['discount_value'] as num).toDouble(),
      active: json['active'],
    );
  }

  // Validate if the code is valid
  static bool validatePromoCode(String code) {
    return code.length >= 5;
  }

  // Validate if the code is active
  static bool isPromoCodeActive(PromoCode promoCode) {
    return promoCode.active;
  }

  // Apply discount to cart total
  static double applyPromoCode(PromoCode promoCode, double cartTotal) {
    if (promoCode.discountType == "porcentaje") {
      return cartTotal - (cartTotal * promoCode.discountValue / 100);
    } else if (promoCode.discountType == "fijo") {
      return cartTotal - promoCode.discountValue;
    }
    return cartTotal;
  }
}
