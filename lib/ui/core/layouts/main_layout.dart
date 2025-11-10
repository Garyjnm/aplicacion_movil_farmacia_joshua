import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicacion_movil_farmacia_joshua/sidebar_widget.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/core/themes/theme_provider.dart';

@RoutePage(name: 'MainLayoutRoute')
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      drawer: const SidebarWidget(),
      appBar: AppBar(
        title: const Text('Farmacia Joshua'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Cambiar a claro' : 'Cambiar a oscuro',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: const AutoRouter(),
    );
  }
}