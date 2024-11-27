import 'package:choi_pos/widgets/login_form.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/choi-image.png'), height: 40),
            SizedBox(height: 10),
            Text('Inicia sesión en Choi POS',
                style: TextStyle(color: Colors.white, fontSize: 18)),

            // Login Form
            Padding(padding: EdgeInsets.symmetric(horizontal: 600, vertical: 20), child: LoginForm())
          ],
        ),
      ),
    );
  }
}
