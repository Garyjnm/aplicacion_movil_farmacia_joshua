import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
// La nueva clase HomeScreen que usa Riverpod (ConsumerWidget)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("Botón Elevado"),
          ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Buscar...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home),
                Icon(Icons.favorite),
                Icon(Icons.settings),
              ],
            ),
            const SizedBox(height: 10),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Card de prueba"),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Tema actual: ${isDark ? "Oscuro 🌙" : "Claro ☀️"}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}