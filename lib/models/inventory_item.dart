class InventoryItem {
  final String id;
  final String barcode;
  final String category;
  final String name;
  final double price;
  final int quantity;

  InventoryItem({
    required this.id,
    required this.barcode,
    required this.category,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Recieve from JSON
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      barcode: json['bar_code'],
      category: json['category'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  // Return to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bar_code': barcode,
      'category': category,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
