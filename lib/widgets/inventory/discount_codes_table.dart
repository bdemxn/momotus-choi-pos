import 'dart:convert';
import 'package:choi_pos/models/promo_code.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Service Class
class PromoCodeService {
  static const String apiUrl = 'http://45.79.205.216:8000/admin/promos';

  Future<List<PromoCode>> getPromoCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((e) => PromoCode.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar los promocodes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener los promocodes: $e');
    }
  }
}

// PromoCode Table Widget
class PromoCodeTable extends StatelessWidget {
  final List<PromoCode> promoCodes;

  const PromoCodeTable({super.key, required this.promoCodes});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Código')),
        DataColumn(label: Text('Tipo de Descuento')),
        DataColumn(label: Text('Valor del Descuento')),
        DataColumn(label: Text('Activo')),
      ],
      rows: promoCodes
          .map(
            (promo) => DataRow(
              cells: [
                DataCell(Text(promo.code)),
                DataCell(Text(promo.discountType)),
                DataCell(Text(promo.discountValue.toString())),
                DataCell(Text(promo.active ? 'Sí' : 'No')),
              ],
            ),
          )
          .toList(),
    );
  }
}

// Main Screen
class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({Key? key}) : super(key: key);

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  late Future<List<PromoCode>> promoCodesFuture;

  @override
  void initState() {
    super.initState();
    promoCodesFuture = PromoCodeService().getPromoCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Códigos de Promoción'),
      ),
      body: FutureBuilder<List<PromoCode>>(
        future: promoCodesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: PromoCodeTable(promoCodes: snapshot.data!),
            );
          } else {
            return const Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }
}
