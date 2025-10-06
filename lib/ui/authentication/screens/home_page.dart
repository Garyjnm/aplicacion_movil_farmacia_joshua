import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/theme_provider.dart';
import '../../../sidebar_widget.dart';

// La nueva clase HomeScreen que usa Riverpod (ConsumerWidget)
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // La lógica del cambio de tema se integra directamente aquí, 
  // ya que este widget puede acceder a Riverpod.
  void _onToggleTheme(WidgetRef ref) {
    final current = ref.read(themeProvider);
    // Cambia el estado del proveedor de tema
    ref.read(themeProvider.notifier).state =
        current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary, 
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            // Llama a la función local que usa Riverpod
            onPressed: () => _onToggleTheme(ref), 
            tooltip: "Cambiar tema",
          ),
        ],
      ),
      drawer: const SidebarWidget(), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Elementos de la interfaz del segundo código
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
              // Añadir un texto para mostrar el tema actual (opcional)
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Tema actual: ${isDark ? "Oscuro 🌙" : "Claro ☀️"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}