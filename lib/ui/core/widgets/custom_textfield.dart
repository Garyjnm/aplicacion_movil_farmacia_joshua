import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText; // 👈 ahora es propiedad de la clase

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false, // 👈 valor por defecto (no requerido)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText, // 👈 ahora sí se usa aquí
      style: TextStyle(color: colors.onPrimaryContainer),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.onPrimaryContainer),
        filled: true,
        fillColor: colors.primaryContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
