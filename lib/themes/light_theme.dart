import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  //Colores
  colorScheme: const ColorScheme(
    brightness: Brightness.light, 
    primary: Color(0xFFBED6E3), 
    onPrimary: Color(0xFF1B194B), 
    secondary: Color(0xFFA3BECD), 
    onSecondary: Color(0xFF1B194B), 
    tertiary: Color(0xFF6D8D9F),
    onTertiary: Color(0xFFF4F4F4) ,
    error: Color(0xFFE6F2F9 ), 
    onError: Color(0xFF4D0A0F), 
    surface: Color(0xFFF4F4F4), 
    onSurface: Colors.black,
    ),
  //Fuentes
  fontFamily: "Segoe UI",
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12) ),
  useMaterial3: true
);