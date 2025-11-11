import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType; 

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType, 
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