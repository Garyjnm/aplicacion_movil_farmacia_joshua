import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:aplicacion_movil_farmacia_joshua/sidebar_widget.dart';

@RoutePage()
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarWidget(),
      appBar: AppBar(
        title: const Text('Farmacia Joshua'),
      ),
      body: const AutoRouter(),
    );
  }
}