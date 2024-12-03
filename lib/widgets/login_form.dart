import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Form controllers:
  final _formKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField("Usuario", userController),
            const SizedBox(height: 10),
            _inputField("Contraseña", passwordController, isPassword: true),
            // Buttons:
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (userController.text == "alan.arguello" && passwordController.text == "Prueba1#") {
                        context.go('/admin');
                      }
                    },
                    child: const Text(
                      'Admin Center',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (userController.text == "alan.arguello" && passwordController.text == "Prueba1#" || userController.text == 'cajero1' && passwordController.text == 'Testing123@') {
                        context.go('/app');
                      }
                    },
                    child: const Text(
                      'POS App',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {isPassword = false}) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white));

    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: border,
          focusedBorder: border,
          fillColor: Colors.black26),
      obscureText: isPassword,
    );
  }
}
