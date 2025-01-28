import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BundleService {
  final List<Bundle> _bundles = [];

  List<Bundle> get bundles => _bundles;

  Future<void> fetchBundles() async {
    const String apiUrl = 'http://216.238.86.5:8000/admin/bundles';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No se encontró un token de autenticación.');
      }

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        _bundles.clear();
        _bundles.addAll(data.map((item) => Bundle.fromJson(item)));
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al hacer fetch: $e');
    }
  }
}

class Bundle {
  final String id;
  final String name;
  final double totalPrice;
  final List<ProductInBundle> products;

  Bundle({
    required this.id,
    required this.name,
    required this.totalPrice,
    required this.products,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'],
      name: json['name'],
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
      products: (json['products'] as List<dynamic>)
          .map((item) => ProductInBundle.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_price': totalPrice,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class ProductInBundle {
  final String id;
  final int quantity;
  final double discount;

  ProductInBundle({
    required this.id,
    required this.quantity,
    required this.discount,
  });

  factory ProductInBundle.fromJson(Map<String, dynamic> json) {
    return ProductInBundle(
      id: json['id'],
      quantity: json['quantity'],
      discount: json['discount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'discount': discount,
    };
  }
}
