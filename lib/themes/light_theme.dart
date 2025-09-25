import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  //Colores
  colorScheme: const ColorScheme(
    brightness: Brightness.light, 
    primary:Color(0xFFE6F2F9),
    onPrimary: Color(0xFF1B194B),
    primaryContainer: Color(0xFFBED6E3),
    onPrimaryContainer: Color(0xFF1B194B),
    secondary: Color(0xFFA3BECD), 
    onSecondary: Color(0xFF1B194B), 
    secondaryContainer: Color(0xFF6D8D9F),
    onSecondaryContainer: Color(0xFFF4F4F4),
    tertiary: Color(0xFF4D0A0F),
    error: Color(0xFFE6F2F9 ), 
    onError: Color(0xFF4D0A0F), 
    surface: Color(0xFFF4F4F4), 
    onSurface: Color(0xFF1B194B),
    ),
  //Fuentes
  fontFamily: "Segoe UI",
  textTheme: const TextTheme(
    //Titulos
    titleLarge: TextStyle(fontSize: 24),
    titleMedium: TextStyle(fontSize: 22),
    titleSmall: TextStyle(fontSize: 20),
    //texto de párrafos o contenido principal)
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    bodySmall: TextStyle(fontSize: 14),
    //labels en botones
    labelLarge: TextStyle(fontSize: 12),
    labelMedium: TextStyle(fontSize: 11),
    labelSmall: TextStyle(fontSize: 10),
    ),
  useMaterial3: true
);