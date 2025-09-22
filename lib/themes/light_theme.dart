import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light, 
    primary: Color(0xFFBED6E3), 
    onPrimary: Color(0xFF1B194B), 
    secondary: Color(0xFFA3BECD), 
    onSecondary: Color(0xFF1B194B), 
    error: Color(0xFFE6F2F9 ), 
    onError: Color(0xFF4D0A0F), 
    surface: Color(0xFFF4F4F4), 
    onSurface: Colors.black,
    ),
  useMaterial3: true
);