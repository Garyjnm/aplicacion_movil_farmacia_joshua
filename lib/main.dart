import 'package:flutter/material.dart';
import 'package:aplicacion_movil_farmacia_joshua/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmacia Joshua',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Roboto'),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}