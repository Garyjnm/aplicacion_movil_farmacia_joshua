import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ajuste de tamaño para distintos anchos
        final double maxLogoWidth = constraints.maxWidth < 500 ? constraints.maxWidth * 0.7 : 360;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxLogoWidth),
              child: Image.asset(
                'assets/images/farmacia joshua logo definitivo.png',
                fit: BoxFit.contain,
                semanticLabel: 'Logo Farmacia Joshua',
              ),
            ),
          ),
        );
      },
    );
  }
}