import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PromoForm extends StatefulWidget {
  const PromoForm({super.key});

  @override
  _PromoFormState createState() => _PromoFormState();
}

class _PromoFormState extends State<PromoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _type = "porcentaje";

  Future<void> _createPromoCode() async {
    const String apiUrl = 'http://45.79.205.216:8000/admin/promos';

    if (_formKey.currentState!.validate()) {
      final promoCode = {
        "code": _codeController.text,
        "discount_type": _type,
        "discount_value": double.parse(_valueController.text),
        "active": true,
      };

      try {
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('authToken');
        
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode(promoCode),
        );

        print(promoCode);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Promo code creado exitosamente.")),
          );
          _codeController.clear();
          _valueController.clear();
          setState(() {
            _type = "porcentaje";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error al crear promo code: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de red: $e")),
        );
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Promo Code"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "Código"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El código es requerido.";
                  }
                  if (!PromoCode.validatePromoCode(value)) {
                    return "El código debe tener al menos 5 caracteres.";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                      value: "porcentaje", child: Text("Porcentaje")),
                  DropdownMenuItem(value: "fijo", child: Text("Fijo")),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: "Tipo"),
              ),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: "Valor"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El valor es requerido.";
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return "Ingresa un valor válido.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createPromoCode,
                child: const Text("Crear Promo Code"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromoCode {
  static bool validatePromoCode(String code) {
    return code.length >= 5;
  }
}
