import 'package:flutter/material.dart';

class CustomCreateButton extends StatelessWidget {
  final String label; // Texto del botón
  final VoidCallback onPressed; // Acción al presionar
  final IconData icon; // Ícono del botón

  const CustomCreateButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add, // Por defecto será un "+" (add)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBED6E3),
        foregroundColor: const Color(0xFF1B194B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );
  }
}
