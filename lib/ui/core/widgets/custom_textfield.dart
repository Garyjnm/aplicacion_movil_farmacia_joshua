import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled; 
  final Color? fillColor; // permite personalizar el fondo

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true, 
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled, 
      style: TextStyle(
        color: enabled
            ? colors.onPrimaryContainer
            : colors.onSurfaceVariant, 
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
        ),
        filled: true,
        // Fondo blanco por defecto de forma global (si no se especifica).
        fillColor: fillColor ?? (enabled
          ? Colors.white
          : colors.surfaceVariant), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
