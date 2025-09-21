import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: '',); //este controlador nos permite obtener el texto del campo de usuario
  final TextEditingController _passwordController = TextEditingController(); //este controlador nos permite obtener el texto del campo de contraseña

  @override
  void dispose() {
    _usernameController.dispose(); //liberamos los recursos del controlador cuando ya no se necesita
    _passwordController.dispose(); //liberamos los recursos del controlador cuando ya no se necesita
    super.dispose(); 
  }

  void _login() {
    final username = _usernameController.text; //obtenemos el texto del campo de usuario
    final password = _passwordController.text; //obtenemos el texto del campo de contraseña

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(
          content: Text('Por favor ingrese usuario y contraseña'), //mensaje de error si el usuario o la contraseña estan vacios
          duration: Duration(seconds: 2),
          ),
      );
      return;
    }
  }
}