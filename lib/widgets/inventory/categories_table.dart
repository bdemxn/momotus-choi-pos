import 'package:choi_pos/services/category/get_categories.dart';
import 'package:flutter/material.dart';

class CategoryTable extends StatefulWidget {
  const CategoryTable({super.key});

  @override
  State<CategoryTable> createState() => _CategoryTableState();
}

class _CategoryTableState extends State<CategoryTable> {
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    // Carga las categorías al iniciar
    _categoriesFuture = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar categorías: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay categorías registradas.'),
          );
        }

        final categories = snapshot.data!;

        return Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text('Categoría',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: categories.map(
                  (category) {
                    return DataRow(cells: [
                      DataCell(Text(category)),
                    ]);
                  },
                ).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
