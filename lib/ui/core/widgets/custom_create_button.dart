import 'package:flutter/material.dart';

class CustomCreateButton extends StatelessWidget {
  final String label; // Texto del botón
  final VoidCallback onPressed; // Acción al presionar
  final IconData icon; // Ícono del botón
  final Alignment? alignment; // align the button if needed
  final double? width; // optional fixed width to standardize across screens

  const CustomCreateButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add, // Por defecto será un "+" (add)
    this.alignment,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBED6E3),
        foregroundColor: const Color(0xFF1B194B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // linea responsable de que el boton no ocupe todo el ancho
        minimumSize: width != null ? Size(width!, 48) : const Size(0, 48),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );

    if (width != null) {
      button = SizedBox(width: width, child: button);
    }

    if (alignment != null) {
      return Align(alignment: alignment!, child: button);
    }

    return button;
  }
}
