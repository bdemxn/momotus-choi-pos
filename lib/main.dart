import 'package:choi_pos/router/app_router.dart';
import 'package:choi_pos/services/bundles/get_bundles.dart';
import 'package:choi_pos/services/inventory/get_inventory.dart';
import 'package:choi_pos/services/monthly/monthly_services.dart';
import 'package:choi_pos/services/tournaments/tournament_services.dart';
import 'package:choi_pos/store/cart_provider.dart';
import 'package:choi_pos/store/user_provider.dart';
import 'package:choi_pos/theme/dark_theme.dart';// Importa CartProvider
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // Añade CartProvider aquí
        Provider(create: (_) => InventoryService()), // Añade el InventoryService aquí
        Provider(create: (_) => TournamentServices()), 
        Provider(create: (_) => BundleService()),
        Provider(create: (_) => MonthlyServices())
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      routerConfig: appRouter,
    );
  }
}
