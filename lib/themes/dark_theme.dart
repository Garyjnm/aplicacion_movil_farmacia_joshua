import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark, 
    primary: Color(0xFF1B194B), 
    onPrimary: Color(0xFFF4F4F4), 
    secondary: Color(0xFFA3BECD), 
    onSecondary: Color(0xFF1B194B), 
    error: Color(0xFFE6F2F9 ), 
    onError: Color(0xFF4D0A0F), 
    surface: Color(0xFF040325), 
    onSurface: Colors.white,
    ),
  useMaterial3: true
);
