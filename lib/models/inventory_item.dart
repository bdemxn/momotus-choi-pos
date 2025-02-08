class InventoryItem {
  final String id;
  final String name;
  final double price;
  final String barCode;
  final int quantity;
  final String category;
  final String currency;


  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.barCode,
    required this.quantity,
    required this.category,
    required this.currency
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      barCode: json['bar_code'],
      quantity: json['quantity'],
      category: json['category'],
      currency: json['currency']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'barCode': barCode,
      'quantity': quantity,
      'category': category,
    };
  }
}
