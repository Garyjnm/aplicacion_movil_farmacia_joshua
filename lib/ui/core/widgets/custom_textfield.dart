import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  // ✨ AÑADIR LA PROPIEDAD readOnly ✨
  final bool readOnly; 

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.readOnly = false, // Establecer valor por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      // ✨ PASAR LA PROPIEDAD readOnly AL WIDGET INTERNO ✨
      readOnly: readOnly, 
      
      // La lógica del color es importante si usas 'enabled: false'
      // Si usas 'readOnly: true' y 'enabled: true', el color debe ser el normal.
      style: TextStyle(
        color: enabled 
            ? colors.onSurface
            : colors.onSurfaceVariant,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? colors.onSurface
              : colors.onSurfaceVariant,
        ),

        filled: true,
        fillColor: isDark ? colors.surfaceVariant : Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
        ),
        // Si el campo no está habilitado, usa un borde distinto
        disabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(
             color: colors.outline.withOpacity(0.3),
           ),
        ),
      ),
    );
  }
}