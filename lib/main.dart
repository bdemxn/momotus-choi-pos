import 'package:choi_pos/screens/admin/overview_screen.dart';
import 'package:choi_pos/screens/app_screen.dart';
import 'package:choi_pos/screens/forgot_screen.dart';
import 'package:choi_pos/screens/login_screen.dart';
import 'package:choi_pos/theme/dark_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgotPassword': (context) => const ForgotScreen(),
        '/app': (context) => const AppScreen(),
        '/admin': (context) => const OverviewScreen()
      },
    );
  }
}
