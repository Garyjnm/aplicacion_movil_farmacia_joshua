import 'package:flutter/material.dart';
import 'sidebar_widget.dart';
// import 'theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: const HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      // drawer: const SidebarWidget(), // <-- Aquí referenciamos el sidebar
      body: const Center(
        child: Text('FARMACIA JOSHUA', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
